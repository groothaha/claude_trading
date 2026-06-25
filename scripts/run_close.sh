#!/bin/zsh
# cron 래퍼 — 미 장 마감 직후 청산·손익 기록. headless claude 에이전트 루프.
export PATH="/opt/homebrew/bin:/Users/yunjiho/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd /Users/yunjiho/claude_trading || exit 1
[ -f .env ] && source .env
source scripts/config.sh
mkdir -p state journal/daily
echo "===== $(date '+%F %T %Z') CLOSE run =====" >> state/cron.log
timeout 900 "$CLAUDE_BIN" -p "$(cat prompts/close.md)" \
  --model "$CT_MODEL" \
  --dangerously-skip-permissions \
  < /dev/null >> state/cron.log 2>&1
echo "----- CLOSE done rc=$? $(date '+%F %T') -----" >> state/cron.log
