# 安全 Key 变更记录

> 记录时间：2026-06-10 23:29

## 已更换的 Key

### 1. OpenClaw Gateway Token ✅
- 更换时间：2026-06-10 ~22:30
- 新值：c9184c777231c2f0be9c34f623beaee84fdf8cbcf1a03f1f69f5fe2286beaa36
- 已重启生效

### 2. DeepSeek API Key ✅
- 更换时间：2026-06-10 ~22:30
- 新值：sk-2de…de5d（已写入 openclaw.json）

### 3. COS 密钥 ✅
- 更换时间：2026-06-10 ~23:25
- 新 SecretId：AKIDW4…ElFY
- 新 SecretKey：JRN6cx868EZAnQvX4SffT5VloyPjAW2V
- 已更新 ~/.cos.conf，备份测试通过

### 4. GitHub SSH 密钥对（进行中）
- 新公钥：ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIASMk0mTshyHYvdJ551SMNaNxLYZWW+nnojOaR9gpLeE naidou-server-20260608-new
- 新私钥：~/.ssh/id_ed25519_new
- 待操作：
  - [ ] 新公钥添加到 GitHub：https://github.com/settings/keys
  - [ ] 新公钥添加到 GitCode：https://gitcode.com/settings/ssh
  - [ ] 配置 ~/.ssh/config 指向新密钥
