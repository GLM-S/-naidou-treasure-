# 重装恢复清单

> 生成时间：2026-06-10 22:30
> 适用：Ubuntu 22.04 全新系统重装后

---

## 一、基础环境（restore-v2.sh 自动完成）

- [ ] 运行 `bash /home/ubuntu/.openclaw/workspace/scripts/restore-v2.sh`
- [ ] 等待所有步骤完成
- [ ] 重新登录 SSH

---

## 二、恢复 openclaw.json 配置

将以下内容写入 `~/.openclaw/openclaw.json`：

### 关键配置项

```json
{
  "agents": {
    "defaults": {
      "workspace": "/home/ubuntu/.openclaw/workspace",
      "model": {
        "primary": "deepseek/deepseek-v4-flash"
      },
      "memorySearch": {
        "provider": "openai-compatible",
        "model": "text-embedding-v3",
        "fallback": "none",
        "remote": {
          "baseUrl": "https://api.deepseek.com/v1",
          "apiKey": "sk-4c7…343e"
        }
      }
    }
  },
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "sk-4c7…343e",
        "api": "openai-completions",
        "models": [
          {"id": "deepseek-v4-flash", "name": "DeepSeek V4 Flash"},
          {"id": "deepseek-v4-pro", "name": "DeepSeek V4 Pro"}
        ]
      },
      "agnes": {
        "baseUrl": "https://apihub.agnes-ai.com/v1",
        "apiKey": "sk-22m…XCAy",
        "api": "openai-completions",
        "models": [
          {"id": "Agnes-2.0-Flash", "name": "Agnes 2.0 Flash"},
          {"id": "Agnes-Image-2.0-Flash", "name": "Agnes Image 2.0 Flash"},
          {"id": "Agnes-Video-V2.0", "name": "Agnes Video V2.0"}
        ]
      }
    },
    "mode": "merge"
  },
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "b9d2263420a7bce0caa93b141cb5a38b5251dad02dfc5153"
    },
    "port": 20966,
    "bind": "lan",
    "controlUi": {
      "allowedOrigins": ["http://101.34.82.153:20966"],
      "allowInsecureAuth": true,
      "dangerouslyDisableDeviceAuth": true,
      "basePath": "/s06240"
    }
  },
  "channels": {
    "lightclawbot": {
      "enabled": true,
      "accounts": {
        "100048985454": {
          "apiKey": "e72dc4660abc9350db55194d68cb5f0d1ce27c7b"
        }
      }
    },
    "wecom": {
      "enabled": true,
      "connectionMode": "websocket",
      "botId": "aib_5qXXR5a-TkbsUH1HvEUXzn-Wh5wuI1Y",
      "secret": "4w1aDQriME2fpNyO9IoLCslpDTQyEsaLWRuDV3On6q0",
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "groupAllowFrom": ["*"]
    }
  },
  "browser": {
    "enabled": true,
    "executablePath": "/home/ubuntu/.cache/ms-playwright/chromium-1223/chrome-linux64/chrome",
    "noSandbox": true,
    "defaultProfile": "user",
    "profiles": {
      "user": {
        "cdpUrl": "http://localhost:9222",
        "driver": "existing-session",
        "attachOnly": true,
        "color": "#4285F4",
        "userDataDir": "/home/ubuntu/.openclaw/browser-existing-session"
      }
    },
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    }
  }
}
```

---

## 三、恢复 COS 密钥

写入 `~/.cos.conf`：

```ini
[common]
secret_id = AKIDoY…4fGv
secret_key = c2Lq8DHF5oOxPgnleNwKafZJwOfkdJn4
bucket = naidou-1434426321
region = ap-guangzhou
max_thread = 5
part_size = 1
retry = 5
timeout = 60
schema = https
verify = md5
anonymous = False
```

---

## 四、恢复燃气险 HTML 文件

从聊天记录中复制粘贴源码（或从 treasure 仓库恢复）：
- `cp.html` — 产品介绍
- `kh.html` — 销售话术
- `al.html` — 理赔案例

放到 `/home/ubuntu/.openclaw/workspace/` 目录下

---

## 五、启动服务

```bash
# 1. 启动 Meilisearch（如果 restore-v2.sh 没启动）
docker start meilisearch

# 2. 启动静态页面服务
pm2 start "npx serve /home/ubuntu/.openclaw/workspace -l 8080" --name naidu-serve -- -s
pm2 save

# 3. 启动 OpenClaw
openclaw gateway start  # 或 openclaw gateway restart

# 4. 同步记忆到 Meilisearch
python3 /home/ubuntu/.openclaw/workspace/bin/sync-memory.py

# 5. 启动 Cloudflare Tunnel（如果需要）
cloudflared tunnel run
```

---

## 六、恢复定时任务

```bash
# 每5分钟同步 memory → Meilisearch
(crontab -l 2>/dev/null; echo "*/5 * * * * python3 /home/ubuntu/.openclaw/workspace/bin/sync-memory.py > /dev/null 2>&1") | crontab -

# 每天4点同步 memory → COS 备份
(crontab -l 2>/dev/null; echo "0 4 * * * python3 /home/ubuntu/.openclaw/workspace/bin/backup-to-cos.py > /dev/null 2>&1") | crontab -
```

---

## 七、验证

- [ ] `http://101.34.82.153:8080/cp.html` 能打开
- [ ] `http://101.34.82.153:8080/kh.html` 能打开
- [ ] `http://101.34.82.153:8080/al.html` 能打开
- [ ] 企业微信能发消息、能收到回复
- [ ] Meilisearch 能搜索：`curl http://127.0.0.1:7700/indexes/memory/search -d '{"q": "测试"}'`
- [ ] COS 音频能播放

---

## 八、安全加固（建议）

1. **GitHub 仓库设为 private**（如果之前是公开的）
2. **更换 API Key**（如果怀疑泄露）：
   - DeepSeek API Key
   - Agnes API Key
   - COS 密钥
   - WeCom Secret
   - OpenClaw Gateway Token
3. **配置 UFW 防火墙**：
   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 8080/tcp  # 静态页面
   sudo ufw allow 20966/tcp # OpenClaw
   sudo ufw enable
   ```

---

## 紧急联系方式

- **服务器 IP**：101.34.82.153
- **腾讯云控制台**：https://console.cloud.tencent.com/
- **GitHub 仓库**：git@github.com:GLM-S/-naidou-treasure-.git
- **GitCode 仓库**：git@gitcode.com:gcw_e7bz63KA/naidou-treasure.git
