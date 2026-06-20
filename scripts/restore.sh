#!/bin/bash
# ============================================================
# 静渊服务器 · 一键恢复脚本 v2.0
# 用法：在全新 Ubuntu 22.04/24.04 上执行：
#   bash <(curl -sL https://raw.githubusercontent.com/GLM-S/-naidou-treasure-/main/scripts/restore.sh)
# 或克隆仓库后本地执行：
#   cd ~/naidou-treasure && bash scripts/restore.sh
# ============================================================

set -e

# ========== 配置 ==========
GITHUB_REPO_HTTPS="https://github.com/GLM-S/-naidou-treasure-.git"
GITHUB_CLONE_DIR="$HOME/naidou-treasure"
WORKSPACE_DIR="$HOME/.openclaw/workspace"
DATA_DISK="/dev/vdb"
DATA_MOUNT="/mnt/data"
MY_IP=$(curl -s ifconfig.me 2>/dev/null || echo "获取失败")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  静渊服务器 · 一键恢复 v2.0${NC}"
echo -e "${GREEN}  时间：$(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${GREEN}  系统：$(lsb_release -ds 2>/dev/null || cat /etc/os-release | head -1)${NC}"
echo -e "${GREEN}  IP：${MY_IP}${NC}"
echo -e "${GREEN}========================================${NC}"

# ========== 1. 基础系统 ==========
step() { echo -e "\n${YELLOW}[$1/$TOTAL] $2${NC}"; }
TOTAL=9

step 1 "系统基础更新"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim ufw ca-certificates gnupg lsb-release unzip

# ========== 2. 数据盘挂载 ==========
step 2 "挂载数据盘"
if lsblk | grep -q "$(basename $DATA_DISK)"; then
  if ! mount | grep -q "$DATA_DISK"; then
    sudo mkdir -p "$DATA_MOUNT"
    sudo mount "$DATA_DISK" "$DATA_MOUNT"
    echo "$DATA_DISK $DATA_MOUNT ext4 defaults 0 0" | sudo tee -a /etc/fstab
    echo -e "${GREEN}数据盘已挂载到 $DATA_MOUNT${NC}"
  else
    echo -e "${GREEN}数据盘已挂载${NC}"
  fi
else
  echo -e "${YELLOW}未检测到数据盘，跳过${NC}"
fi

# ========== 3. 安装 Node.js 和 pnpm ==========
step 3 "安装 Node.js + pnpm"
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt install -y nodejs
fi
if ! command -v pnpm &>/dev/null; then
  npm install -g pnpm
fi
echo "Node: $(node -v) | pnpm: $(pnpm -v)"

# ========== 4. 安装 OpenClaw ==========
step 4 "安装 OpenClaw"
if ! command -v openclaw &>/dev/null; then
  pnpm install -g openclaw@latest
fi
echo "OpenClaw: $(openclaw --version 2>/dev/null || echo '已安装')"

# ========== 5. 从 GitHub 拉取仓库 ==========
step 5 "拉取宝藏库"
if [ ! -d "$GITHUB_CLONE_DIR" ]; then
  git clone "$GITHUB_REPO_HTTPS" "$GITHUB_CLONE_DIR"
  echo -e "${GREEN}仓库已克隆到 $GITHUB_CLONE_DIR${NC}"
else
  cd "$GITHUB_CLONE_DIR" && git pull
  echo -e "${GREEN}仓库已更新${NC}"
fi

# ========== 6. 恢复 workspace 文件 ==========
step 6 "恢复 workspace（技能+记忆+恢复脚本）"
mkdir -p "$WORKSPACE_DIR"

# 恢复 skills 目录（自定义技能）
if [ -d "$GITHUB_CLONE_DIR/skills" ]; then
  rsync -a "$GITHUB_CLONE_DIR/skills/" "$WORKSPACE_DIR/skills/" 2>/dev/null || \
  cp -rn "$GITHUB_CLONE_DIR/skills/"* "$WORKSPACE_DIR/skills/" 2>/dev/null || true
  echo -e "${GREEN}技能已恢复${NC}"
fi

# 恢复 memory 目录（记忆文件）
if [ -d "$GITHUB_CLONE_DIR/memory" ]; then
  mkdir -p "$WORKSPACE_DIR/memory"
  rsync -a "$GITHUB_CLONE_DIR/memory/" "$WORKSPACE_DIR/memory/" 2>/dev/null || \
  cp -rn "$GITHUB_CLONE_DIR/memory/"* "$WORKSPACE_DIR/memory/" 2>/dev/null || true
  echo -e "${GREEN}记忆文件已恢复${NC}"
fi

# 恢复核心配置文件（MEMORY.md / SOUL.md 等）
for f in MEMORY.md SOUL.md USER.md IDENTITY.md TOOLS.md HEARTBEAT.md AGENTS.md; do
  if [ -f "$GITHUB_CLONE_DIR/$f" ]; then
    cp "$GITHUB_CLONE_DIR/$f" "$WORKSPACE_DIR/$f"
  fi
done

# 恢复 server 文件
if [ -f "$GITHUB_CLONE_DIR/server.js" ]; then
  cp "$GITHUB_CLONE_DIR/server.js" "$WORKSPACE_DIR/"
fi
if [ -f "$GITHUB_CLONE_DIR/package.json" ]; then
  cp "$GITHUB_CLONE_DIR/package.json" "$WORKSPACE_DIR/"
fi
if [ -f "$GITHUB_CLONE_DIR/serve.json" ]; then
  cp "$GITHUB_CLONE_DIR/serve.json" "$WORKSPACE_DIR/"
fi

# 恢复恢复脚本自身
cp "$GITHUB_CLONE_DIR/scripts/restore.sh" "$WORKSPACE_DIR/scripts/"

echo -e "${GREEN}workspace 文件已恢复${NC}"

# ========== 7. 恢复 OpenClaw 配置 ==========
step 7 "恢复 OpenClaw 配置"
# 注意：openclaw.json 包含敏感密钥（API Key、企微配置等）
# 需要从安全备份恢复，这里输出指引
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
  echo -e "${GREEN}OpenClaw 配置已存在，跳过${NC}"
else
  echo -e "${YELLOW}"
  echo "  ⚠️ OpenClaw 配置文件 ($HOME/.openclaw/openclaw.json) 包含："
  echo "     - API Keys（DeepSeek、智谱等）"
  echo "     - 企业微信 Bot 配置"
  echo "     - COS 密钥"
  echo ""
  echo "  🔑 恢复方式："
  echo "    方法A：从旧服务器的 ~/.openclaw/openclaw.json 手动拷贝"
  echo "    方法B：openclaw configure 重新配置"
  echo "    方法C：备份在 COS 冷备桶中，用 coscli 下载"
  echo -e "${NC}"
fi

# ========== 8. 安装 server 依赖并启动 ==========
step 8 "启动静态服务"
cd "$WORKSPACE_DIR"
if [ -f "package.json" ]; then
  npm install --production 2>/dev/null || true
fi
if ! pm2 list 2>/dev/null | grep -q naidou-serve; then
  if [ -f "server.js" ]; then
    pm2 start server.js --name naidou-serve 2>/dev/null || \
    npx serve -s . -l 8080 &
    echo -e "${GREEN}静态服务已启动${NC}"
  fi
fi
pm2 save 2>/dev/null || true

# ========== 9. 完成 ==========
step 9 "完成"
echo -e "${GREEN}"
echo "========================================" 
echo "  ✅ 恢复完成！"
echo "========================================"
echo -e "${NC}"
echo ""
echo "  📌 后续手动步骤："
echo ""
echo "  1. 恢复敏感配置（必做）："
echo "     cp ~/naidou-treasure/backup/openclaw.json ~/.openclaw/openclaw.json"
echo "     或从旧服务器 scp："
echo "     scp ubuntu@旧IP:~/.openclaw/openclaw.json ~/.openclaw/"
echo ""
echo "  2. 恢复 SSH Key（Git推送用）："
echo "     cp ~/naidou-treasure/backup/id_ed25519* ~/.ssh/"
echo "     chmod 600 ~/.ssh/id_ed25519"
echo ""
echo "  3. 恢复 COS 配置："
echo "     cp ~/naidou-treasure/backup/.cos.conf ~/"
echo ""
echo "  4. 配置 OpenClaw 企业微信通道："
echo "     openclaw gateway configure"
echo ""
echo "  5. 启动 OpenClaw："
echo "     openclaw gateway start"
echo ""
echo "  6. 验证状态："
echo "     openclaw status"
echo ""
echo "  💾 备份管理："
echo "    仓库：${GITHUB_REPO_HTTPS}"
echo "    COS冷备桶：naidou-1434426321"
echo ""
echo "  📂 重要路径："
echo "    workspace：$WORKSPACE_DIR"
echo "    OpenClaw配置：~/.openclaw/openclaw.json"
echo "    数据盘：$DATA_MOUNT（若有）"
echo ""
