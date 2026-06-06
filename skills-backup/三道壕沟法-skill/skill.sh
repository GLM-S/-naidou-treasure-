#!/usr/bin/env bash

# Local skill registry — 三道壕沟法
declare -A SKILLS=(
  [三道壕沟法-skill]="skills/三道壕沟法-skill/SKILL.md"
)

if [[ $# -eq 0 ]]; then
  echo "Usage: source ./skill.sh <skill-name>"
  echo "Available skills: ${!SKILLS[@]}"
else
  echo "${SKILLS[$1]}"
fi
