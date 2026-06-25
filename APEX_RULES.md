# APEX $50K — 하드 제약 규격

이 계정 모델은 APEX Trader Funding 50K 평가계정 기준이며, 모든 매매 결정의 하드 제약이다.

| 항목 | 값 |
|---|---|
| 시작 잔고 | $50,000 |
| 트레일링 드로다운 | $2,500 (피크 **EOD** equity 기준) |
| DD 플로어 락 | peak ≥ $52,600 이면 floor = $50,000 (브레이크이븐 고정), 아니면 floor = peak − $2,500 |
| 이익 목표(통과) | +$3,000 → equity $53,000 |
| 최대 계약수 | 10 NQ (초기엔 1–2 권장) |
| 일일 리스크 캡 | 최악 손절손실 ≤ $500, 그리고 (equity − floor) 이상 절대 리스크 X |
| 일관성 룰 | 단일일 이익 ≤ 누적이익의 30% (플래그만, 차단 X) |
| 상품 | NQ E-mini ($20/pt, tick 0.25pt=$5) |
| 보유 | 인트라데이만, 오버나잇 금지, EOD 전량청산 |
| 마찰비용 | 왕복 $14/계약 = 수수료 $4 + 슬리피지 1틱/편(0.5pt=$10) |

## 손익 계산
```
dir   = +1(LONG) / -1(SHORT)
손절체결: LONG low ≤ entry-stop  또는 SHORT high ≥ entry+stop → net = -(N*stop*20) - N*14
일반:     gross = dir*(exit-entry)*N*20 ; net = gross - N*14
```

## equity 갱신
```
cum += net ; equity = 50000 + cum ; peak = max(peak, equity)
floor = 50000 if peak>=52600 else peak-2500
status = BLOWN if equity<=floor else (PASSED if equity>=53000 else ACTIVE)
trading_days += 1  (계약>0 인 날만)
```

## 2026 잔여 미 휴장(전일휴장)
07-03, 09-07, 11-26, 12-25 — 매매 없음.
반일(조기 13:00 ET 마감): 11-27, 12-24.
