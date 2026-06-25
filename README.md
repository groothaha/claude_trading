# claude_trading — NQ 데일리 모의매매 (APEX $50K)

매 미국 거래일, headless `claude`(opus 4.8) 에이전트가 **로컬 cron**으로 두 번 돈다:

- **장 시작(09:30 ET)** — 그날 뉴스/시황/실적/매크로 캘린더 조사 → NQ 방향·사이즈 결정 → `state/open_position.json` 기록·커밋
- **장 마감(16:00 ET)** — NQ 종가로 청산 → 당일 손익·누적 equity·APEX 컴플라이언스 갱신 → `journal/` 커밋

> ⚠️ 검증된 엣지가 아니라 **재량 판단 기록 실험**이다. 본인 선행연구에서 NQ 인트라데이 진입 알파 ≈ 0 으로 확인됨. 수익이 아니라 "규율 있는 기록"이 목적.

## 구조
```
prompts/open.md    장시작 결정 프롬프트(자체완결)
prompts/close.md   장마감 청산·기록 프롬프트
scripts/config.sh  모델·경로
scripts/run_open.sh / run_close.sh   cron 래퍼
journal/equity.csv  일자별 equity/peak/DD/status   ← 누적 진실원장
journal/trades.csv  일자별 진입·청산·손익
journal/daily/*.md  당일 상세 로그
journal/RESULTS.md  한 줄 요약 누적
state/             전이상태(open_position.json)·cron.log  [gitignore]
APEX_RULES.md      $50K 하드 제약 규격
```

## 실행 방식 — 로그인된 CLI 세션 루프 (토큰·cron 불필요)
이 봇은 **이미 로그인된 Claude Code CLI 세션 안에서** self-paced 루프로 돈다(ScheduleWakeup).
세션 인증을 그대로 쓰므로 **API키·`setup-token`·cron 전부 불필요.** (세션이 떠 있는 동안 발동.)
- **장시작 틱**(09:30 ET ≈ 22:30 KST): `prompts/open.md` 절차로 진입 결정·기록
- **장마감 틱**(16:00 ET ≈ 05:05 KST): `prompts/close.md` 절차로 청산·기록
- 매 틱이 다음 이벤트까지 ScheduleWakeup 재설정(최대 1h, 이벤트 임박 시 정밀하게).
- 휴장일(07-03·09-07·11-26·12-25)은 감지해 "거래없음" 기록.

### (선택) cron/headless 폴백 — 세션 못 띄울 때만
`scripts/run_open.sh`·`run_close.sh`는 cron용 폴백이다. 단 cron은 로그인 세션 밖이라
Keychain 인증을 못 쓰므로 이때만 `claude setup-token` → `.env`의 `CLAUDE_CODE_OAUTH_TOKEN`
주입이 필요하다. 기본 운영(CLI 루프)에선 쓰지 않는다.

## 수동 실행/점검
```
~/claude_trading/scripts/run_open.sh    # 지금 한 번 진입런
~/claude_trading/scripts/run_close.sh   # 청산런
tail -f ~/claude_trading/state/cron.log
cat journal/RESULTS.md
```
