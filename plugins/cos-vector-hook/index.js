/**
 * COS Vector Hook Plugin
 * 在 before_prompt_build 阶段用 fetch 调用 COS 向量桶 API
 * 检索相关知识注入到 system prompt
 */

function getConfig(pluginConfig) {
  return {
    region: pluginConfig?.region || "ap-guangzhou",
    bucket: pluginConfig?.bucket || "my-knowledge-base-1434426321",
    index: pluginConfig?.index || "my-index",
    topK: pluginConfig?.topK || 5,
  };
}

/**
 * 通过 DeepSeek API 做文本 embedding
 * 返回 float32 向量数组
 */
async function getEmbedding(text) {
  const apiKey = "sk-4c70143c4f524b0aa9a7fbb7dabf343e";
  const resp = await fetch("https://api.deepseek.com/v1/embeddings", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiKey,
    },
    body: JSON.stringify({
      model: "text-embedding-v3",
      input: [text],
    }),
  });

  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error("embedding API error " + resp.status + ": " + errText);
  }

  const data = await resp.json();
  return data.data[0].embedding;
}

/**
 * 构造 COS QueryVectors API 的签名
 * 使用 HMAC-SHA1 签名（AWS Signature V2 风格）
 */
function buildCosVectorsQuery(region, bucket, vector, index, topK) {
  // 构建请求体
  const body = JSON.stringify({
    vectorBucketName: bucket,
    indexName: index,
    queryVector: { float32: vector },
    topK: topK,
    returnMetadata: true,
    returnDistance: true,
  });

  return { body, endpoint: "vectors." + region + ".coslake.com" };
}

/**
 * 查询 COS 向量桶
 * 使用腾讯云 COS API 签名
 */
async function searchVectors(queryText, cfg) {
  // 1. 获取 embedding
  const embedding = await getEmbedding(queryText);

  // 2. 构造签名请求
  const secretId = process.env.COS_VECTORS_SECRET_ID;
  const secretKey = process.env.COS_VECTORS_SECRET_KEY;
  if (!secretId || !secretKey) {
    throw new Error("COS_VECTORS_SECRET_ID/KEY not set");
  }

  const endpoint = "vectors." + cfg.region + ".coslake.com";
  const body = JSON.stringify({
    vectorBucketName: cfg.bucket,
    indexName: cfg.index,
    queryVector: { float32: embedding },
    topK: cfg.topK,
    returnMetadata: true,
    returnDistance: true,
  });

  // 使用腾讯云 HMAC-SHA1 签名（COS API v1 签名）
  const date = new Date().toUTCString();
  const md5hex = await sha1(body);
  const signStr = "POST\n" + md5hex + "\napplication/json\n" + date + "\n/QueryVectors";
  const signature = await hmacSha1(secretKey, signStr);

  const resp = await fetch("https://" + endpoint + "/QueryVectors", {
    method: "POST",
    headers: {
      "Host": endpoint,
      "Date": date,
      "Content-Type": "application/json",
      "Content-MD5": md5hex,
      "Authorization": "q-sign-algorithm=sha1&q-ak=" + secretId + "&q-sign-time=&q-key-time=&q-header-list=date;host&q-url-param-list=&q-signature=" + signature,
    },
    body: body,
    signal: AbortSignal.timeout(10000),
  });

  if (!resp.ok) {
    const errText = await resp.text();
    if (resp.status === 401 || resp.status === 403) {
      // 签名错误，改用 Python 脚本模式
      throw new Error("auth_error");
    }
    throw new Error("COS query error " + resp.status + ": " + errText);
  }

  return await resp.json();
}

// HMAC-SHA1 辅助函数
async function sha1(str) {
  const data = new TextEncoder().encode(str);
  const hash = await crypto.subtle.digest("SHA-1", data);
  return btoa(String.fromCharCode(...new Uint8Array(hash)));
}

async function hmacSha1(key, data) {
  const enc = new TextEncoder();
  const cryptoKey = await crypto.subtle.importKey(
    "raw", enc.encode(key),
    { name: "HMAC", hash: "SHA-1" },
    false, ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", cryptoKey, enc.encode(data));
  return btoa(String.fromCharCode(...new Uint8Array(sig)));
}

// SHA-256 辅助函数  
async function sha256(str) {
  const data = new TextEncoder().encode(str);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map(b => b.toString(16).padStart(2, "0"))
    .join("");
}

function formatResults(response) {
  if (!response || !response.vectors || response.vectors.length === 0) {
    return null;
  }

  const items = response.vectors.map(function(v) {
    const meta = v.metadata || {};
    const title = meta.title || "";
    const content = meta.content || meta.text || "";
    const scoreText = v.distance !== undefined
      ? "[得分:" + (1 - Math.min(v.distance, 1)).toFixed(2) + "]"
      : "";
    return scoreText + " " + (title ? "**" + title + "**\n" : "") + content;
  }).filter(Boolean);

  if (items.length === 0) return null;
  return "\n\n【COS 知识库相关记忆】\n" + items.join("\n\n");
}

let setupDone = false;

export default async function handler(event) {
  if (event.type !== "before_prompt_build") {
    return;
  }

  const cfg = getConfig(event.context && event.context.pluginConfig);

  if (!setupDone) {
    console.log("[cos-vector-hook] initialized: region=" + cfg.region + ", bucket=" + cfg.bucket + ", index=" + cfg.index);
    setupDone = true;
  }

  const userPrompt = event.prompt || "";
  if (!userPrompt || userPrompt.trim().length < 3) {
    return;
  }

  try {
    const result = await searchVectors(userPrompt, cfg);
    const contextStr = formatResults(result);
    if (contextStr) {
      return { appendSystemContext: contextStr };
    }
  } catch (err) {
    if (err.message === "auth_error") {
      console.log("[cos-vector-hook] Signing not available via JS, COS must be called via Python. Skipping.");
    } else {
      console.error("[cos-vector-hook] error:", err.message);
    }
  }
}
