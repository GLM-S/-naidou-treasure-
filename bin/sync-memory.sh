#!/bin/bash
# sync-memory.sh - 把 memory/ 目录下的所有文件同步到 Meilisearch
# 用法: ./sync-memory.sh [--watch]

MEILI="http://127.0.0.1:7700"
INDEX="memory"
WORKSPACE="/home/ubuntu/.openclaw/workspace"

# 如果没有参数或参数是 --watch，则只执行一次同步
sync_once() {
  local files=($(find "$WORKSPACE/memory/" -name "*.md" -newer "$WORKSPACE/memory/.last-sync" 2>/dev/null))
  
  if [ ${#files[@]} -eq 0 ]; then
    # 首次运行，全量同步
    files=($(find "$WORKSPACE/memory/" -name "*.md" 2>/dev/null))
    touch "$WORKSPACE/memory/.last-sync"
  fi

  if [ ${#files[@]} -eq 0 ]; then
    echo "[sync] 没有文件需要同步"
    return
  fi

  # 构建批量写入 JSON
  local docs="[]"
  for f in "${files[@]}"; do
    local basename=$(basename "$f")
    local title="${basename%.md}"
    local content=$(cat "$f")
    
    # 追加到文档数组
    docs=$(echo "$docs" | python3 -c "
import json,sys
docs = json.load(sys.stdin)
docs.append({
    'id': title,
    'title': basename,
    'content': open('$f').read(),
    'path': '$f',
    'updatedAt': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
})
print(json.dumps(docs))
")
  done

  # 写入 Meilisearch
  echo "$docs" | curl -s -X POST "$MEILI/indexes/$INDEX/documents" \
    -H 'Content-Type: application/json' \
    -d @- > /dev/null

  echo "[sync] 同步了 ${#files[@]} 个文件"
  touch "$WORKSPACE/memory/.last-sync"
}

# 执行同步
sync_once
