#!/usr/bin/env python3
"""
backup-to-cos.py - 把 memory/ 和 workspace 关键文件备份到 COS
每天执行一次

用法: python3 backup-to-cos.py
"""

import os, time, json, subprocess, glob
from datetime import datetime

WORKSPACE = os.path.expanduser("/home/ubuntu/.openclaw/workspace")
MEMORY_DIR = os.path.join(WORKSPACE, "memory")
COS_ALIAS = "naidou"
COS_BACKUP_DIR = "openclaw-memory-backup"

today = datetime.now().strftime("%Y-%m-%d")
backup_path = f"{COS_BACKUP_DIR}/{today}/"

# 1. 备份 memory/*.md 文件
memory_files = glob.glob(os.path.join(MEMORY_DIR, "*.md"))

if not memory_files:
    print("❌ 没有找到 memory/*.md 文件")
    exit(1)

uploaded = 0
for f in memory_files:
    basename = os.path.basename(f)
    dest = f"cos://{COS_ALIAS}/{backup_path}{basename}"
    result = subprocess.run(
        ["coscli", "cp", f, dest],
        capture_output=True, text=True, timeout=30
    )
    if result.returncode == 0:
        uploaded += 1
    else:
        print(f"  ❌ {basename}: {result.stderr.strip()}")

print(f"📤 上传 {uploaded}/{len(memory_files)} 个记忆文件到 COS")

# 2. 备份 MEMORY.md 和配置文件
extra_files = [
    os.path.join(WORKSPACE, "MEMORY.md"),
    os.path.join(WORKSPACE, "openclaw.json"),
    os.path.join(WORKSPACE, "TOOLS.md"),
]

extra_config = os.path.expanduser("/home/ubuntu/.openclaw/openclaw.json")
if os.path.exists(extra_config):
    extra_files.append(extra_config)

for f in extra_files:
    if os.path.exists(f):
        basename = os.path.basename(f)
        dest = f"cos://{COS_ALIAS}/{backup_path}config/{basename}"
        subprocess.run(
            ["coscli", "cp", f, dest],
            capture_output=True, text=True, timeout=30
        )

print(f"📤 配置文件上传完成")

# 3. 清理：只保留最近 30 天的备份
result = subprocess.run(
    ["coscli", "ls", f"cos://{COS_ALIAS}/{COS_BACKUP_DIR}/"],
    capture_output=True, text=True, timeout=15
)

old_dirs = []
for line in result.stdout.strip().split("\n"):
    if line.strip() and line.strip() != "KEY":
        parts = line.split()
        if len(parts) >= 3 and parts[0].endswith("/"):
            dir_name = parts[0].rstrip("/")
            if dir_name.startswith("20") and "-" in dir_name:
                try:
                    dt = datetime.strptime(dir_name, "%Y-%m-%d")
                    if (datetime.now() - dt).days > 30:
                        old_dirs.append(dir_name)
                except:
                    pass

for d in old_dirs:
    subprocess.run(
        ["coscli", "rm", f"cos://{COS_ALIAS}/{COS_BACKUP_DIR}/{d}/", "-r"],
        capture_output=True, timeout=30
    )
    print(f"🗑️ 清理旧备份: {d}")

print(f"✅ COS 备份完成 ({today})")
