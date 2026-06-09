#!/bin/bash
TEXT="$1"
OUTPUT="${2:-/tmp/speech.mp3}"
edge-tts --voice zh-CN-YunxiNeural --text "$TEXT" --write-media "$OUTPUT"
echo "音频已生成: $OUTPUT"
