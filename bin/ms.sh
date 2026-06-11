#!/bin/bash
# Meilisearch 记忆搜索工具
# 用法: ./ms.sh <搜索关键词>

if [ -z "$1" ]; then
  echo "用法: ./ms.sh <搜索关键词>"
  exit 1
fi

curl -s -X POST 'http://127.0.0.1:7700/indexes/memory/search' \
  -H 'Content-Type: application/json' \
  -d "{\"q\":\"$*\",\"limit\":10}" | python3 -c "
import json,sys
d = json.load(sys.stdin)
hits = d.get('hits',[])
print(f'找到 {len(hits)} 条结果:\n')
for i, h in enumerate(hits, 1):
    t = h.get('title','?')
    c = h.get('content','')[:200].replace('\n',' ')
    print(f'{i}. [{t}]')
    print(f'   {c}')
    print()
" 2>&1
