#!/bin/bash
# 批量生成场景旁白 MP3
# 用法: bash scripts/gen-audio.sh <pageID> <audio_dir>
# 输入: 从 stdin 读取 "sceneID|文本" 逐行
# 输出: audio/{pageID}_{sceneID}.mp3

PAGE_ID="${1:-cp}"
AUDIO_DIR="${2:-audio}"
VOICE="zh-CN-XiaoxiaoNeural"
RATE="0%"

mkdir -p "$AUDIO_DIR"

while IFS='|' read -r scene_id text; do
  [ -z "$scene_id" ] && continue
  outfile="${AUDIO_DIR}/${PAGE_ID}_${scene_id}.mp3"
  echo "→ 生成: $outfile"
  edge-tts --voice "$VOICE" --rate "$RATE" --text "$text" --write-media "$outfile" 2>/dev/null
done

echo "✅ 全部生成完毕"
