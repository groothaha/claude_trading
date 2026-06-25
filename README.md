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

## ⚙️ 활성화에 필요한 단 한 단계 (인증)
cron은 로그인 세션 밖이라 macOS Keychain의 Claude 인증을 못 쓴다. 터미널에서:
```
claude setup-token
```
출력된 `sk-ant-oat...` 토큰을 `~/claude_trading/.env` 에 넣는다:
```
export CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat...
```
(`.env`는 gitignore됨. 이게 비어 있으면 cron 런이 "Not logged in"으로 실패.)

## cron (mac 로컬 = KST, 현재 EDT 시즌)
```
30 22 * * 1-5  ~/claude_trading/scripts/run_open.sh    # 09:30 ET 진입
5  5  * * 2-6  ~/claude_trading/scripts/run_close.sh   # 16:05 ET 청산
```
- **DST 주의:** 미 EST 전환(2026-11-01) 후엔 1시간 늦춰 `30 23 * * 1-5` / `5 6 * * 2-6`.
- **맥이 깨어 있어야** cron이 발동(`caffeinate`/전원설정).
- 휴장일은 에이전트가 감지해 "거래없음" 기록.

## 수동 실행/점검
```
~/claude_trading/scripts/run_open.sh    # 지금 한 번 진입런
~/claude_trading/scripts/run_close.sh   # 청산런
tail -f ~/claude_trading/state/cron.log
cat journal/RESULTS.md
```
