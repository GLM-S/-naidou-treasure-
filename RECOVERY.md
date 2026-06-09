# 服务器恢复保障清单

## 前提条件
- [ ] GitHub 仓库（GLM-S/naidou-treasure）有最新的配置备份
- [ ] GitHub token 或 SSH key 已配置（用于 git push）
- [ ] COS 存储桶密钥有效

## 一键恢复
在全新 Ubuntu 22.04 上执行：
```bash
bash <(curl -sL https://raw.githubusercontent.com/GLM-S/naidou-treasure/main/scripts/restore.sh)
```

或本地运行：
```bash
bash scripts/restore.sh
```

## 恢复后操作
1. 重新登录使 docker 用户组生效
2. 配置 API Key（DeepSeek、Tavily、COS 等）
3. 恢复 OpenClaw 配置
4. 检查 cron 任务（早报、寻宝、备份）

## 手动备份（无 GitHub 时）
```bash
# 备份记忆文件
tar czf memory-backup-$(date +%Y%m%d).tar.gz memory/ MEMORY.md drafts/
# 上传到 COS
```

## 关键路径
- 配置文件：scripts/restore.sh
- 记忆文件：memory/*.md + MEMORY.md
- 稿件：drafts/
- 燃气险页面：cp.html kh.html al.html
