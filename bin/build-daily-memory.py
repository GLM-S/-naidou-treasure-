#!/usr/bin/env python3
"""
build-daily-memory.py - 从当天的对话记录中提取关键信息，
写入 memory/YYYY-MM-DD.md，自动同步进 Meilisearch

用法: 每次对话结束后调用一次
"""

import json, os, glob, urllib.request, textwrap
from datetime import datetime

WORKSPACE = os.path.expanduser("/home/ubuntu/.openclaw/workspace")
MEMORY_DIR = os.path.join(WORKSPACE, "memory")
TDAI_DIR = os.path.expanduser("/home/ubuntu/.openclaw/memory-tdai/conversations")
MEILI = "http://127.0.0.1:7700"
INDEX = "memory"

os.makedirs(MEMORY_DIR, exist_ok=True)

today = datetime.now().strftime("%Y-%m-%d")
today_file = os.path.join(MEMORY_DIR, f"{today}.md")
today_tdai = os.path.join(TDAI_DIR, f"{today}.jsonl")

# 1. 读取今天所有的对话
messages = []
if os.path.exists(today_tdai):
    with open(today_tdai) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    msg = json.loads(line)
                    messages.append(msg)
                except:
                    pass

print(f"📖 今天共 {len(messages)} 条消息")

# 2. 提取关键信息（从对话中提取有决策/结论的内容）
# 由于这里是后台脚本，简单提取人话部分
summary_lines = []
user_msgs = []
for msg in messages:
    role = msg.get("role", "")
    content = msg.get("content", "")
    if role == "user" and content and len(content) > 5:
        # 去除可能的重复/语气词
        line = content.strip().replace("\n", " ")[:200]
        user_msgs.append(line)

# 3. 写入或追加到今天的记忆文件
if user_msgs:
    # 看看是否已有今天的文件
    if os.path.exists(today_file):
        with open(today_file, 'r') as f:
            existing = f.read()
        # 追加新的对话摘要
        with open(today_file, 'a') as f:
            f.write(f"\n\n## 对话记录\n\n")
            for msg in user_msgs[-10:]:  # 只保留最近10条
                f.write(f"- {msg}\n")
        print(f"📝 追加到 {today_file}")
    else:
        # 新建
        with open(today_file, 'w') as f:
            f.write(f"# {today} 日志\n\n## 对话记录\n\n")
            for msg in user_msgs[-20:]:  # 保留最近20条
                f.write(f"- {msg}\n")
        print(f"📝 新建 {today_file}")

# 4. 同步到 Meilisearch
doc_id = today.replace("-", "")
doc_path = today_file

with open(doc_path) as f:
    content = f.read()

doc = [{
    "id": doc_id,
    "title": f"{today}.md",
    "content": content,
    "path": doc_path,
    "updatedAt": datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
}]

try:
    data = json.dumps(doc).encode()
    req = urllib.request.Request(
        f"{MEILI}/indexes/{INDEX}/documents",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        r = json.loads(resp.read())
    print(f"✅ 同步到 Meilisearch 成功")
except Exception as e:
    print(f"❌ 同步到 Meilisearch 失败: {e}")
