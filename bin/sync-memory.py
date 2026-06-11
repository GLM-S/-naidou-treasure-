#!/usr/bin/env python3
"""sync-memory.py - 把 memory/*.md 同步到 Meilisearch"""

import json, os, urllib.request, glob, time

MEILI = "http://127.0.0.1:7700"
INDEX = "memory"
MEMORY_DIR = os.path.expanduser("/home/ubuntu/.openclaw/workspace/memory")

def ms_request(method, path, data=None):
    url = f"{MEILI}/{path}"
    req = urllib.request.Request(url, method=method,
                                 headers={"Content-Type": "application/json"})
    if data is not None:
        req.data = json.dumps(data).encode()
    try:
        with urllib.request.urlopen(req, timeout=5) as resp:
            return json.loads(resp.read())
    except Exception as e:
        print(f"  ❌ {e}")
        return None

# 1. 清除旧索引（重建，确保干净）
print("🗑️ 删除旧索引...")
ms_request("DELETE", f"indexes/{INDEX}")

# 2. 建新索引
print("📦 创建新索引...")
ms_request("POST", "indexes", {"uid": INDEX, "primaryKey": "id"})

# 3. 批量写入所有记忆文件
print("📖 读取记忆文件...")
files = sorted(glob.glob(os.path.join(MEMORY_DIR, "*.md")))
docs = []
for f in files:
    basename = os.path.basename(f)
    name = basename.replace(".md", "")
    with open(f) as fh:
        content = fh.read()
    docs.append({
        "id": name,
        "title": basename,
        "content": content,
        "path": f,
        "updatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    })

print(f"📤 写入 {len(docs)} 条记忆到 Meilisearch...")
result = ms_request("POST", f"indexes/{INDEX}/documents", docs)
if result:
    print(f"✅ 同步完成！")

# 4. 验证
stats = ms_request("GET", f"indexes/{INDEX}/stats")
if stats:
    print(f"📊 索引统计: {stats.get('numberOfDocuments', 0)} 条记录")
