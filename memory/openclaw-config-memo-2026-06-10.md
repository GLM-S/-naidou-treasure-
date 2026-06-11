# OpenClaw 配置备忘录
> 保存时间：2026-06-10
> 实例：OpenClaw(龙虾)-iN6N | lhins-8dmteyga | IP: 101.34.82.153 | 地域: 上海（rid=4）

---

## 本次会话解决的问题

### 1. 配置文件损坏修复
- **问题**：`models.providers.deepseek` 和 `models.providers.agnes` 配置无效
- **修复命令**：`openclaw doctor --fix`（以 ubuntu 用户执行）
- **结果**：配置从备份恢复，网关重启成功

### 2. DeepSeek API Key 丢失
- **问题**：`doctor --fix` 恢复备份时覆盖了 apiKey，导致企业微信无法回复
- **修复命令**：
  ```bash
  openclaw config set models.providers.deepseek.apiKey sk-4c70143c4f524b0aa5a57a59258a343e
  openclaw gateway restart
  ```

### 3. Agnes 副引擎配置写入
- **问题**：`agnes` 提供商被清除，需重新写入
- **Agnes AI 信息**：
  - 官方介绍：全球榜单前十 AI Lab，2026-06-01 起三大模型 API 无限期免费
  - baseUrl：`https://apihub.agnes-ai.com/v1`
  - apiKey：`sk-22m162W6Xp6Yt6P4ghwBmDfBaTh3w2sCNMHTIpJAW28TXCAy`
  - 模型列表：
    - `Agnes-2.0-Flash`（文本）
    - `Agnes-Image-2.0-Flash`（图像）
    - `Agnes-Video-V2.0`（视频）
- **修复命令**（用 jq 写入，需对象数组格式）：
  ```bash
  jq '.models.providers.agnes = {
    "baseUrl": "https://apihub.agnes-ai.com/v1",
    "apiKey": "sk-22m162W6Xp6Yt6P4ghwBmDfBaTh3w2sCNMHTIpJAW28TXCAy",
    "api": "openai-completions",
    "models": [
      {"id": "Agnes-2.0-Flash", "name": "Agnes 2.0 Flash"},
      {"id": "Agnes-Image-2.0-Flash", "name": "Agnes Image 2.0 Flash"},
      {"id": "Agnes-Video-V2.0", "name": "Agnes Video V2.0"}
    ]
  }' ~/.openclaw/openclaw.json > /tmp/openclaw.tmp \
  && mv /tmp/openclaw.tmp ~/.openclaw/openclaw.json \
  && openclaw gateway restart
  ```

---

## 当前模型提供商配置（已验证可用）

| 提供商 | baseUrl | 可用模型 |
|--------|---------|----------|
| deepseek | https://api.deepseek.com/v1 | deepseek-v4-flash, deepseek-v4-pro |
| agnes | https://apihub.agnes-ai.com/v1 | Agnes-2.0-Flash, Agnes-Image-2.0-Flash, Agnes-Video-V2.0 |

---

## 企业微信（WeCom）频道配置

- Bot ID：`aib_5qXXR5a-TkbsUH1HvEUXzn-Wh5wuI1Y`
- Secret：`4w1aDQriME2fpNyO9IoLCslpDTQyEsaLWRuDV3On6q0`
- 当前状态：已连接（WebSocket OK）

---

## 注意事项

1. **执行命令必须以 ubuntu 用户身份运行**，root 用户找不到 node（nvm 安装在 ubuntu 下）
2. **`openclaw config set` 不支持写入数组**，模型列表必须用 `jq` 直接编辑配置文件
3. **`doctor --fix` 会覆盖 apiKey**，修复后需重新写入 DeepSeek 和 Agnes 的 Key
4. 配置文件路径：`~/.openclaw/openclaw.json`（ubuntu 用户 home 目录）

---

## 待处理警告（不影响使用）

- discord / whatsapp / slack 插件未安装（可选）
- lightclawbot 频道缺少 `accounts.default` 绑定
- API Key 以明文存储，建议执行 `openclaw secrets configure` 迁移
