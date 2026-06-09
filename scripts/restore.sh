#!/bin/bash
# ============================================================
# 静渊服务器 · 一键恢复脚本
# 用法：在全新 Ubuntu 22.04 上执行：
#   curl -sL https://raw.githubusercontent.com/GLM-S/naidou-treasure/main/scripts/restore.sh | bash
# 或本地执行：
#   bash restore.sh
# ============================================================

set -e

echo "========================================"
echo " 静渊服务器 · 一键恢复 "
echo " 适用：Ubuntu 22.04 全新系统"
echo "========================================"

# ---------- 配置区（执行前按需修改）----------
GITHUB_REPO="git@github.com:GLM-S/naidou-treasure.git"
GITHUB_REPO_HTTPS="https://github.com/GLM-S/naidou-treasure.git"
WORKSPACE_DIR="$HOME/.openclaw/workspace"
DIFY_DIR="$HOME/dify"
DATA_DISK_MOUNT="/mnt/data"

# ---------- 1. 系统基础 ----------
echo ""
echo "[1/8] 系统基础更新..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim ufw ca-certificates gnupg lsb-release

# ---------- 2. 安装 Docker ----------
echo ""
echo "[2/8] 安装 Docker..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  sudo usermod -aG docker $USER
fi
docker --version

# ---------- 3. 配置 Docker 国内镜像 ----------
echo ""
echo "[3/8] 配置 Docker 国内镜像源..."
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
echo "[4/8] 挂载数据盘..."
if lsblk | grep -q vdb; then
  sudo mkdir -p "$DATA_DISK_MOUNT"
  if ! mount | grep -q vdb; then
    sudo mount /dev/vdb "$DATA_DISK_MOUNT"
    echo "/dev/vdb $DATA_DISK_MOUNT ext4 defaults 0 0" | sudo tee -a /etc/fstab
    echo "数据盘已挂载到 $DATA_DISK_MOUNT"
  else
    echo "数据盘已挂载"
  fi
fi

# ---------- 5. 从 GitHub 拉取配置 ----------
echo ""
echo "[5/8] 从 GitHub 拉取配置文件..."
if [ ! -d "$HOME/naidou-treasure" ]; then
  git clone "$GITHUB_REPO_HTTPS" "$HOME/naidou-treasure" 2>/dev/null || \
  git clone "https://kkgithub.com/GLM-S/naidou-treasure.git" "$HOME/naidou-treasure"
fi

# 如果 clone 成功，恢复配置文件
if [ -d "$HOME/naidou-treasure" ]; then
  echo "配置文件已拉取到 $HOME/naidou-treasure"
  
  # 恢复 docker-compose
  if [ -f "$HOME/naidou-treasure/docker-compose.yml" ]; then
    cp "$HOME/naidou-treasure/docker-compose.yml" "$HOME/"
    echo "docker-compose.yml 已恢复"
  fi
  
  # 恢复环境变量
  if [ -f "$HOME/naidou-treasure/.env" ]; then
    cp "$HOME/naidou-treasure/.env" "$HOME/"
    echo ".env 已恢复"
  fi
fi

# ---------- 6. 安装 Dify（docker-compose） ----------
echo ""
echo "[6/8] 部署 Dify..."
if [ ! -d "$DIFY_DIR" ]; then
  git clone --depth 1 "https://kkgithub.com/langgenius/dify.git" "$DIFY_DIR" 2>/dev/null || \
  git clone "https://github.com/langgenius/dify.git" "$DIFY_DIR" --depth 1 2>/dev/null || \
  echo "Dify 源码拉取失败，稍后请手动重试"
fi

if [ -f "$DIFY_DIR/docker/docker-compose.yaml" ]; then
  cd "$DIFY_DIR/docker"
  cp docker-compose.yaml docker-compose.yaml.bak
  # 修改端口避免冲突（默认80→8082）
  sed -i 's/"80:80"/"8082:80"/g' docker-compose.yaml
  docker compose up -d 2>/dev/null || echo "Dify 部署需要在配置好 .env 后手动执行 docker compose up -d"
  cd ~
  echo "Dify docker-compose 已就绪"
fi

# ---------- 7. 配置定时备份 ----------
echo ""
echo "[7/8] 配置每日自动备份到 GitHub..."
cat << 'CRON' > /tmp/backup-cron
# 每天凌晨2点备份到 GitHub
0 2 * * * cd $HOME/naidou-treasure && git add -A && git commit -m "auto-backup $(date +%Y-%m-%d)" && git push 2>/dev/null || echo "backup failed"
CRON
crontab /tmp/backup-cron 2>/dev/null || echo "crontab 配置跳过（需手动设置）"
rm /tmp/backup-cron

# ---------- 8. 完成 ----------
echo ""
echo "========================================"
echo " ✅ 恢复完成！"
echo "========================================"
echo ""
echo "下一步操作："
echo "  1. 重新登录使 Docker 用户组生效： exit → ssh 重新连接"
echo "  2. 配置 GitHub SSH Key： ssh-keygen → cat ~/.ssh/id_ed25519.pub"
echo "  3. 启动 Dify： cd ~/dify/docker && docker compose up -d"
echo "  4. 恢复记忆文件： cp -r ~/naidou-treasure/memory-backup/* ~/.openclaw/workspace/memory/"
echo "  5. 配置 API Key：编辑 ~/naidou-treasure/.env 填入 DeepSeek/其他 Key"
echo ""
echo "详细文档：~/naidou-treasure/README.md"
