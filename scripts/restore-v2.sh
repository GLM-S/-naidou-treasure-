#!/bin/bash
# ============================================================
# 静渊服务器 · 一键恢复脚本 v2
# 适用：Ubuntu 22.04 全新系统（重装后首次运行）
# 用法：bash restore.sh
# ============================================================

set -e

echo "========================================"
echo " 静渊服务器 · 一键恢复 v2"
echo " 适用：Ubuntu 22.04 全新系统"
echo "========================================"

# ---------- 配置区 ----------
WORKSPACE_DIR="$HOME/.openclaw/workspace"

# ---------- 0. 系统基础 ----------
echo ""
echo "[0/10] 系统基础更新..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim ufw ca-certificates gnupg lsb-release apt-transport-https software-properties-common

# ---------- 1. 安装 nvm + Node.js ----------
echo ""
echo "[1/10] 安装 Node.js v22..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install 22
nvm use 22
nvm alias default 22
npm install -g pm2 2>/dev/null || true

# ---------- 2. 安装 Docker ----------
echo ""
echo "[2/10] 安装 Docker..."
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh
sudo usermod -aG docker $USER

# ---------- 3. 配置 Docker 国内镜像 ----------
echo ""
echo "[3/10] 配置 Docker 国内镜像源..."
sudo mkdir -p /etc/docker
cat << 'EOF' | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
sudo systemctl daemon-reexec
sudo systemctl restart docker
sleep 2
echo "Docker 镜像源已配置"

# ---------- 4. 挂载数据盘 ----------
echo ""
echo "[4/10] 挂载数据盘 /dev/vdb..."
sudo mkdir -p /data
if lsblk | grep -q vdb; then
  if ! mount | grep -q "/data"; then
    sudo mkfs.ext4 /dev/vdb 2>/dev/null || true
    sudo mount /dev/vdb /data
    echo "/dev/vdb /data ext4 defaults 0 0" | sudo tee -a /etc/fstab
    echo "数据盘已挂载到 /data"
  else
    echo "数据盘已挂载"
  fi
fi

# ---------- 5. 安装 Playwright Chromium ----------
echo ""
echo "[5/10] 安装 Playwright Chromium..."
sudo apt install -y chromium-browser 2>/dev/null || sudo apt install -y google-chrome-stable 2>/dev/null || echo "Chromium 需要手动安装"

# ---------- 6. 安装 Cloudflare Tunnel ----------
echo ""
echo "[6/10] 安装 Cloudflare Tunnel..."
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
echo "Cloudflare Tunnel 已安装"

# ---------- 7. 安装 Meilisearch ----------
echo ""
echo "[7/10] 安装 Meilisearch..."
docker run -d \
  --name meilisearch \
  -p 7700:7700 \
  -v /data/meilisearch/data:/meili_data \
  getmeili/meilisearch:latest
sleep 2
echo "Meilisearch 已启动（端口 7700）"

# ---------- 8. 从 GitHub 拉取配置 ----------
echo ""
echo "[8/10] 从 GitHub 拉取配置..."
if [ ! -d "$WORKSPACE_DIR" ]; then
  mkdir -p ~/.openclaw
  git clone git@github.com:GLM-S/-naidou-treasure-.git "$WORKSPACE_DIR" 2>/dev/null || \
  git clone https://github.com/GLM-S/-naidou-treasure-.git "$WORKSPACE_DIR" 2>/dev/null || \
  git clone https://kkgithub.com/GLM-S/-naidou-treasure-.git "$WORKSPACE_DIR" 2>/dev/null || \
  echo "GitHub 拉取失败，稍后手动执行"
else
  echo "workspace 已存在"
fi

# ---------- 9. 恢复 SSH 公钥 ----------
echo ""
echo "[9/10] 恢复 SSH 公钥..."
mkdir -p ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUR92AmxG2W+cRyF94yO+TkF9mXrUgC3c1HHavGqTdF naidou-server-20260608" > ~/.ssh/id_ed25519.pub
ssh-keygen -y -f ~/.ssh/id_ed25519 > /dev/null 2>&1 || ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "naidou-server-20260608"

# ---------- 10. 完成 ----------
echo ""
echo "========================================"
echo " ✅ 基础环境恢复完成！"
echo "========================================"
echo ""
echo "下一步："
echo "  1. 重新登录使 Docker 组生效：exit → ssh 重新连接"
echo "  2. 配置 GitHub SSH Key（已自动添加公钥）"
echo "  3. 恢复 openclaw.json 配置（从 treasure 或 COS 备份）"
echo "  4. 恢复 COS 密钥（~/.cos.conf）"
echo "  5. 启动 OpenClaw gateway"
echo ""
echo "手动恢复清单（见 RECOVERY-CHUNK.md）："
echo "  - openclaw.json 完整配置"
echo "  - COS 密钥"
echo "  - API Keys"
echo "  - WeCom 配置"
