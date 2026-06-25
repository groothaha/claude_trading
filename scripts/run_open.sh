#!/bin/zsh
# cron 래퍼 — 미 장 시작 직후 NQ 진입 결정. headless claude 에이전트 루프.
export PATH="/opt/homebrew/bin:/Users/yunjiho/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd /Users/yunjiho/claude_trading || exit 1
# cron은 로그인 세션 밖 → macOS Keychain 인증 불가.
# claude setup-token 으로 만든 sk-ant-oat... 토큰을 .env의 CLAUDE_CODE_OAUTH_TOKEN 에 넣어야 함.
[ -f .env ] && source .env
source scripts/config.sh
mkdir -p state journal/daily
echo "===== $(date '+%F %T %Z') OPEN run =====" >> state/cron.log
timeout 900 "$CLAUDE_BIN" -p "$(cat prompts/open.md)" \
  --model "$CT_MODEL" \
  --dangerously-skip-permissions \
  < /dev/null >> state/cron.log 2>&1
echo "----- OPEN done rc=$? $(date '+%F %T') -----" >> state/cron.log
