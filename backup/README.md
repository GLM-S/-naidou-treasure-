# 备份说明

## 自动备份（已推送到 GitHub）
- skills/ — 所有自定义技能
- memory/ — 记忆文件
- MEMORY.md / SOUL.md 等核心配置文件
- server.js / package.json — 静态服务
- scripts/restore.sh — 一键恢复脚本

## 手动备份（敏感信息，不推送 GitHub）
以下文件包含 API Keys 和密钥，请单独保存到 COS 冷备桶：

| 文件 | 说明 |
|------|------|
| ~/.openclaw/openclaw.json | OpenClaw 完整配置（含 DeepSeek/智谱 API Key、企微 Bot 配置） |
| ~/.openclaw/openclaw-weixin/accounts.json | 企业微信 Bot Token |
| ~/.cos.conf | COS 密钥 |
| ~/.ssh/id_ed25519* | SSH 私钥（GitHub/GitCode 推送用） |

## COS 冷备命令（手动执行）
```bash
# 备份配置文件到 COS
coscli cp ~/.openclaw/openclaw.json cos://naidou-1434426321/backup/openclaw-$(date +%Y%m%d).json
coscli cp ~/.cos.conf cos://naidou-1434426321/backup/cos-conf-$(date +%Y%m%d).txt
coscli cp ~/.ssh/id_ed25519 cos://naidou-1434426321/backup/ssh-key-$(date +%Y%m%d)
coscli cp ~/.openclaw/openclaw-weixin/accounts.json cos://naidou-1434426321/backup/wecom-accounts-$(date +%Y%m%d).json
```

## 恢复流程
1. 装好 Ubuntu 后，执行恢复脚本
2. 从 COS 下载敏感配置
3. 恢复 SSH Key
4. 启动 OpenClaw
