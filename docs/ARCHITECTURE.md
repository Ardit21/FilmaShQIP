# FilmaShQIP — XAUUSD Institutional EA Blueprint

**Version**: 1.0 Final Plan
**Date**: 2026-05-16
**Repo**: `/home/user/FilmaShQIP` (empty, branch `claude/gold-ea-blueprint-8AJ3z`)
**Scope**: Pure architecture & roadmap. Zero MQL5 code until approved.

---

## Context — Pse po e ndërtojmë këtë

Tregtari/zhvilluesi do një Expert Advisor MQL5 për XAUUSD të shkallës "Elite Prop Discipline" — jo një EA retail me indikatorë të vonuar, por një sistem algoritmik që:
- **Mbijeton** çdo stuhi në Live (zero risk of ruin by construction)
- Operon **vetëm intraday** në London/NY (asnjë ekspozim overnight ose weekend)
- Lexon **strukturën institucionale** të çmimit (Price Action + SMC + Volume) jo indikatorët
- Pas validimit me sukses **shitet komercialisht** (MQL5 Market + opsionalisht licensing server)

Sfida kryesore inxhinierike është **anti-curve-fit**: shumica e EA-ve dështojnë në Live sepse janë mbi-optimizuar në backtest. Blueprint-i zgjidh këtë me regime-relative thresholds + walk-forward + Monte Carlo + multi-broker validation. Sfida e dytë është **by-construction prop compliance** — rregullat e prop firms nuk verifikohen ex-post; bëhen strukturalisht të pamundura për t'u shkelur.

**Refinimet e konfirmuara nga përdoruesi**:
- Strategjia: **Hibrid SMC + PA + Volume** (HTF bias SMC → LTF entry PA → Volume confirmation)
- Risk: **3 presets të konfigurueshëm** (PROP / CONSERVATIVE / AGGRESSIVE), të gjitha brenda guard-rails të verifikuara — të zgjedhura me input
- Komerciale: **Vetëm hooks/interface në v1**; implementimi i plotë (MQL5 Market + Self-hosted) vjen pas Forward Test të suksesshëm (Faza 7-8)
- Tooling: **TË KATËRTA** — WFO+MC scripts, Dashboard HUD, Telegram/Email alerts, Advanced JSONL journaling
- Selektiviteti: **Sniper 0–2 setups/ditë A+**

---

## 1. Filozofia & Non-Negotiables

1. **By-construction safety** — `CRiskManager::CanOpenTrade()` refuzon trade-in nëse worst-case SL hit + safety pad do të shkelte daily/max DD. Verifikimi ex-ante, jo ex-post.
2. **XAUUSD obsession** — single-symbol. Contract size 100oz, digits 2 ose 3 (auto-detect), tick-value broker-specific, weekend gap risk, NY-open spread spike.
3. **Regime-relative, JO absolute** — ZERO threshold në pips/USD të hardcoded. Gjithçka ATR-normalized, percentile-based, ose session-relative. Kjo është mburoja kryesore kundër curve-fit.
4. **Sniper, jo scalper** — qëllimi 0–2 A+ trades/ditë. Filtra agresivë në hyrje.
5. **Determinism + idempotency** — restart i platformës nuk prish state. `GlobalVariables` + file backup; OnInit bën reconcile me pozicionet aktive nga `PositionsTotal()` filtruar nga magic.
6. **Observability first** — JSONL trade journal nga dita 1. Çdo refuzim sinjali ka reason të logu.
7. **Mode-as-policy** — 3 presets jo `if-else` të shpërndarë; janë `IRiskPolicy` interface me 3 implementime polimorfike.

---

## 2. Repository Layout

```
FilmaShQIP/
├── FilmaShQIP.mq5                    # Entry point (~150 lines, event handlers only)
├── Include/FilmaShQIP/
│   ├── Core/
│   │   ├── Defines.mqh               # Enums, magic, build flags (#ifdef RELEASE)
│   │   ├── Types.mqh                 # SSwingPoint, SOrderBlock, SFVG, SLiquidityZone, SSignal, STradePlan
│   │   ├── Context.mqh               # CContext — runtime singleton
│   │   └── Errors.mqh
│   ├── Data/
│   │   ├── SymbolMeta.mqh            # Auto-detect XAUUSD digits/contract/tick-value
│   │   ├── TimeService.mqh           # Broker↔UTC↔server, DST table 2020-2030
│   │   ├── BarCache.mqh              # Multi-TF cached OHLCV, new-bar detection
│   │   └── ATR.mqh                   # Rolling ATR per TF + percentile bands
│   ├── Signals/
│   │   ├── MarketStructure.mqh       # Swings, BOS, CHoCH, Premium/Discount
│   │   ├── OrderBlocks.mqh           # OB scanner with displacement + FVG confirm
│   │   ├── FVG.mqh                   # Detect, age, mitigate
│   │   ├── LiquidityScanner.mqh      # EQH/EQL, Asia H/L, PDH/L, PWH/L, sweep detect
│   │   ├── VolumeAnalyzer.mqh        # Tick-vol z-score, absorption, exhaustion
│   │   ├── ConfluenceScorer.mqh      # Weighted score, threshold gate
│   │   └── SignalEngine.mqh          # Orchestrator → SSignal
│   ├── Risk/
│   │   ├── IRiskPolicy.mqh           # Interface (virtual methods)
│   │   ├── PropPolicy.mqh            # FTMO/MFF/FundedNext compliant
│   │   ├── ConservativePolicy.mqh    # Personal low-risk
│   │   ├── AggressivePolicy.mqh      # Personal growth (still bulletproof)
│   │   ├── RiskManager.mqh           # Uses policy via composition
│   │   ├── EquityTracker.mqh         # Peak, daily-anchor, persisted
│   │   └── KillSwitch.mqh            # Trip/reset, manual unlock
│   ├── Execution/
│   │   ├── OrderRouter.mqh           # CTrade wrapper, retries, slippage guard
│   │   ├── PositionManager.mqh       # BE, trail, partials (one-way ratchet)
│   │   └── TradePlan.mqh             # SL/TP factory from signal
│   ├── Filters/
│   │   ├── SessionFilter.mqh         # London/NY/Overlap (Asia=reference only)
│   │   ├── SpreadFilter.mqh          # Session-matched rolling median
│   │   ├── VolatilityFilter.mqh      # ATR spike freeze
│   │   ├── FridayCloseFilter.mqh
│   │   └── FilterChain.mqh           # Short-circuit AND with reason capture
│   ├── News/
│   │   ├── NewsCalendar.mqh          # ForexFactory XML via WebRequest
│   │   ├── NewsFilter.mqh            # Pre/post blackout windows
│   │   └── CalendarCache.mqh         # File fallback (7 days)
│   ├── License/
│   │   ├── ILicenseBackend.mqh       # Interface (hooks-only v1)
│   │   ├── StubBackend.mqh           # v1: pass-through stub w/ demo detection
│   │   ├── MarketBackend.mqh         # v2: full MQL5 Market binding (TBD post-FT)
│   │   ├── ServerBackend.mqh         # v2: HTTPS+JWT (TBD post-FT)
│   │   ├── LicenseGuard.mqh          # Facade
│   │   └── Crypto.mqh                # XOR+SHA256 helpers (anti-decompile friction)
│   ├── Logger/
│   │   ├── Logger.mqh                # Leveled, JSONL file rotation
│   │   └── TradeJournal.mqh          # JSONL append, full trade lifecycle + metadata
│   ├── Alerts/
│   │   ├── IAlertSink.mqh            # Interface
│   │   ├── TelegramSink.mqh          # WebRequest to Bot API
│   │   ├── EmailSink.mqh             # SendMail
│   │   └── AlertDispatcher.mqh       # Routes events to enabled sinks
│   ├── UI/
│   │   ├── Dashboard.mqh             # ChartComment HUD
│   │   └── ChartOverlay.mqh          # Debug ObjectCreate for OB/FVG/zones
│   └── Utils/
│       ├── Math.mqh                  # Percentile, z-score, rolling stats
│       ├── String.mqh
│       └── Persistence.mqh           # GV + file dual-write
└── Tests/
    ├── WFO/                          # Walk-forward configs + Python harness
    ├── MonteCarlo/                   # Trade-shuffle + bootstrap + permutation
    ├── Reports/                      # IS/OOS, MC, stress, multi-broker reports
    └── Configs/                      # Strategy Tester .set files
```

**Total LOC budget**: ~7,500 (lean by institutional standards; 20k+ is bloat).

---

## 3. Strategy Core — Hibrid SMC + PA + Volume

### 3.1 HTF Bias (D1 → H4 → H1)
- Swing detection adaptiv: `L = clamp(round(ATR_pct / baseline), 3, 8)` — JO fix 5
- BOS = close beyond most recent same-side swing; CHoCH = first close against trend
- Bias aggregation: D1 dominant, H4/H1 confirmation (`strong` flag)
- Premium/Discount = 50% Fib of last impulsive range — entries vetëm nga "right side"

### 3.2 HTF Zones (Order Blocks + FVG)
- **OB**: last opposing candle before impulsive BOS; valid if displacement ≥ 1.5×ATR; bonus nëse ka FVG brenda 3 bars; mitigation = close beyond 50% body
- **FVG**: 3-bar imbalance; size ≥ K_FVG_MIN_SIZE × ATR; age-out pas N bars; mitigation tracking në çdo tick

### 3.3 Liquidity & Sweeps
- EQH/EQL clustering me tolerance ATR-fraction
- Asia high/low, PDH/PDL, PWH/PWL
- Sweep = wick-through + close-back në ≤ 5 bars

### 3.4 LTF Triggers (M5 → M1)
Playbook deterministik:
1. Price hyn në HTF zone (OB ose FVG)
2. M5 CHoCH në drejtim të HTF bias
3. M5 breaker block formohet
4. M1 retest i breaker
5. M1 PA trigger: pin bar (wick_ratio>0.6, body<0.3) OSE engulfing (body[0]>1.2×body[1])

### 3.5 Volume Layer (tick-volume proxy)
- Z-score mbi 50 bars
- Effort vs Result divergence
- Absorption: high vol + small range + at zone = institutional accumulation
- Exhaustion: high vol + big wick = reversal hint

### 3.6 Confluence Scoring (0–13, threshold ≥9)
| Factor | Weight | Notes |
|---|---|---|
| HTF D1+H4 bias aligned | 2 | HARD |
| HTF OB/FVG in zone | 2 | HARD |
| Premium/Discount aligned | 1 | |
| Liquidity sweep occurred | 2 | |
| LTF CHoCH confirmed | 2 | HARD |
| LTF breaker + retest | 1 | |
| M1 PA trigger | 1 | |
| Volume absorption at zone | 1 | |
| London/NY session | 1 | HARD via gate |

Gates (jo score): Spread OK, No news, No vol freeze, License OK.

### 3.7 SL/TP
- SL = invalidation level (min(OB.low, breaker.low, swing.low)) − K_SL_BUFFER × ATR(M5)
- TP1 = 1R partial (50% off)
- TP_runner = nearest opposing liquidity ose unmitigated OB; reject if RR < 2.0

---

## 4. Risk Management — 3 Presets Bulletproof

### 4.1 IRiskPolicy interface

```
interface IRiskPolicy {
    double DailyDDCap();
    double DailySoftCapPct();
    double MaxDDCap();
    double RiskPerTradePct();
    double MaxSinglePositionLossPct();
    int    MaxConcurrentPositions();
    bool   AllowPyramiding();
    double LossScaleAfterStreak(int n);
    int    CooldownBarsAfterStreak(int n);
    bool   RequireNewsClose();
    int    MagicSuffix();   // unique per preset → no cross-mode conflict
}
```

### 4.2 Tre presets

| Param | PROP | CONSERVATIVE | AGGRESSIVE |
|---|---|---|---|
| DailyDDCap | 4% | 3% | 6% |
| DailySoftCap | 3% | 2% | 4.5% |
| MaxDDCap | 8% | 6% | 12% |
| Risk/Trade | 0.5% | 0.5% | 1.5% |
| MaxSinglePosLoss | 1% | 1% | 2.5% |
| MaxConcurrent | 1 | 1 | 1 |
| Pyramiding | NO | NO | NO |
| LossScale | {3:0.5, 4:0.25, 5:0.0} | {3:0.5, 5:0.0} | {4:0.5, 6:0.0} |
| Cooldown | aggressive | aggressive | moderate |
| RequireNewsClose | YES | YES | optional |
| MagicSuffix | +1 | +2 | +3 |

**Të treja policies kalojnë testet e Phase 4/5/6**. Përdoruesi zgjedh me `input EPolicyMode inpMode`.

### 4.3 By-construction safety (CanOpenTrade)

```
function CanOpenTrade(plan):
    if kill_switch OR daily_hard_cap OR max_dd: REJECT
    if risk_scalar == 0: REJECT (cooldown)
    if positions_by_magic >= MaxConcurrent: REJECT
    
    sl_dist = abs(entry - sl) / Point
    worst_case = lot * sl_dist * tick_value + slippage_pad + commission
    worst_case *= 1.10  // safety pad
    
    if (daily_loss_now + worst_case) > DailyDDCap * daily_anchor: REJECT
    if (dd_from_peak + worst_case) > MaxDDCap * peak: REJECT
    if daily_loss_now >= DailySoftCapPct * daily_anchor: REJECT
    return ACCEPT
```

### 4.4 Position sizing

5 caps të llogariten, final = `min(all)`:
1. Raw: `equity * risk% / (sl_pts * tick_value)`
2. Daily budget remaining
3. MaxSinglePositionLoss cap
4. MaxDD budget remaining
5. Margin cap (20% free margin max)

Normalize sipas `LotStep`/`MinLot`/`MaxLot`. Nëse < MinLot → reject (budget exhausted).

### 4.5 Equity tracking & kill switch
- Anchor = equity në fillim të broker-day (server midnight)
- Configurable: `inpAnchorKind = EQUITY | BALANCE` (FTMO përdor BALANCE)
- Daily DD breach → auto-reset në midnight tjetër
- Max DD breach → PERMANENT lock; manual reset via `inpManualKillReset` string token
- Persist në GlobalVariables + `Files/FilmaShQIP/state.json`

### 4.6 Order modification (one-way ratchet)
- SL lëviz vetëm drejt BE ose më tej (kurrë më gjerë)
- TP lëviz vetëm më larg (ose qëndron)
- Anti-martingale: pas çdo win → loss_streak=0, risk_scalar=1.0

---

## 5. Filters — Institutional

| Filter | Logic |
|---|---|
| Session | London 07–15 UTC, NY 12–20 UTC, Overlap=prime, DST table |
| Spread | Rolling median session-matched; cap = min(2×median, abs_cap=50pts) |
| Volatility | M5 range > 3×ATR → freeze 6 bars; 3 consecutive >1.5×ATR → freeze 12 |
| News | ForexFactory XML via WebRequest; pre=30min, post=15min; force-close 10min before HIGH if policy.RequireNewsClose |
| FridayClose | Block new entries 17:00 broker; close all 20:00 broker |
| FilterChain | Short-circuit AND, reason captured for journal/dashboard |

**News fail-safe**: nëse WebRequest fails dhe nuk ka cache → assume blackout (block trading).

---

## 6. Commercial Infrastructure — Hooks Only (v1)

### 6.1 v1 Approach
- Implemento **vetëm interfaces** (`ILicenseBackend`, `IAlertSink`) + `CStubBackend` pass-through
- `CLicenseGuard::Enforce()` thirret në çdo tick por v1 stub gjithmonë returns true (përveç testit demo-only nëse aktivizohet)
- Demo/Tester detection funksionon që në v1 (`MQLInfoInteger(MQL_TESTER)`, `ACCOUNT_TRADE_MODE`)
- Logic masking primitiv aktiv që në v1 (split constants, runtime-computed thresholds, `#ifdef RELEASE` strip debug strings)
- **Asnjë WebRequest licence call në v1** — kursehet kompleksiteti dhe pun-e të kotë nëse strategjia s'kalon FT

### 6.2 v2 Approach (post-Phase 7 Forward Test)
- `CMarketBackend`: MQL5 Market binding + offline whitelist hash për enterprise customers
- `CServerBackend`: HTTPS POST → JWT (RS256) → cached me expiry; 72h grace nëse server poshtë
- Vendor public key i ndarë në constants të shumëfishta për mask
- Server-side: cloud VM + certbot + signed JWT + DB për license keys
- Telemetry opt-in (anonymized R-multiples, signal scores)

### 6.3 Inputs në v1 (≤15)

```
input group "═══ Mode & Risk ═══"
input EPolicyMode inpMode = MODE_PROP;   // PROP | CONSERVATIVE | AGGRESSIVE
input double inpRiskPctOverride = 0.0;    // 0 = policy default

input group "═══ Strategy ═══"
input int  inpMinConfluenceScore = 9;     // 9..13
input bool inpAllowOverlapOnly = false;

input group "═══ Filters ═══"
input ENewsImpact inpMinNewsImpact = NEWS_HIGH;
input int inpMaxSpreadPts = 50;
input int inpFridayCloseHourBroker = 20;

input group "═══ Execution ═══"
input long inpMagicBase = 270526001;
input int  inpMaxSlippagePts = 15;

input group "═══ Alerts (opt-in) ═══"
input bool   inpEnableTelegram = false;
input string inpTelegramBotToken = "";
input string inpTelegramChatId = "";
input bool   inpEnableEmail = false;

input group "═══ URLs (whitelist required) ═══"
input string inpCalendarURL = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";

input group "═══ License (v1 stub) ═══"
input string inpLicenseMode = "STUB";     // STUB v1; MARKET/SERVER v2
input string inpLicenseKey = "";

input group "═══ Advanced ═══"
input bool   inpEnableDashboard = true;
input string inpManualKillReset = "";
```

**Count**: 15 (në kufi). Tooling-specifike (Telegram/Email) janë opt-in default OFF.

---

## 7. Tooling — Të Katërta (sipas kërkesës)

### 7.1 WFO + Monte Carlo Scripts (`Tests/WFO/`, `Tests/MonteCarlo/`)
**Python harness** + MT5 Strategy Tester batch runner:
- WFO: 6mo train / 2mo test, step 2mo, 2018-2025 → ~36 windows
- Optimization parameters: VETËM 3 (confluence threshold, ATR displacement, SL buffer)
- MC battery:
  - 1000× trade-order shuffle → P5 equity curve envelope
  - Bootstrap 1000× expectancy 95% CI
  - Permutation test (1000×) vs random bar returns → p-value
  - Spread 2× stress, Slippage 5pts, Latency 200ms
- Output: `Tests/Reports/WFO_v1.md`, `Tests/Reports/MonteCarlo_v1.md`, `Tests/Reports/Stress_v1.md`

### 7.2 Dashboard / HUD on-chart (`UI/Dashboard.mqh`)
ChartComment me update 1s:
```
══════════════════════════════════════════════
  FilmaShQIP v1.0.0   |   XAUUSD Sniper EA
══════════════════════════════════════════════
  Mode: PROP        Tier: STUB-V1
  Session: LONDON   Spread: 18 pts (med 14)
  Vol: NORMAL       News: +2h12m (NFP)
  Equity: $10,247   Peak: $10,520
  Daily DD: -1.2%   Max DD: -2.6%
  Budget Left: $326 today / $814 max
  Loss Streak: 1   Risk Scalar: 100%
  Trades Today: 1 (1W/0L)  Last: BUY +1.4R 09:42
  Last Signal: PENDING — HTF UP, in OB, await CHoCH
══════════════════════════════════════════════
```

### 7.3 Telegram + Email Alerts (`Alerts/`)
- `IAlertSink` interface; `CTelegramSink` (WebRequest Bot API), `CEmailSink` (SendMail)
- `CAlertDispatcher` routes events: signal_generated, trade_opened, trade_closed, kill_switch_trip, daily_dd_warning, news_pause, license_warning
- Rate-limit per sink (max N/hour) për të shmangur spam
- Opt-in via inputs; URL whitelist documented

### 7.4 Advanced Journaling (`Logger/TradeJournal.mqh`)
JSONL format, file rotation daily:
```json
{"ts":"2026-05-16T09:42:11Z","event":"signal","dir":1,"score":11,
 "reasons":["htf_up","obm5","sweep","choch","absorption"],
 "htf_bias":"UP","session":"LONDON","spread_pts":18,
 "atr_h1":4.2,"atr_m5":0.8,"news_next_min":132,
 "policy":"PROP","equity":10247.30,"daily_dd_pct":-1.2,
 "would_enter":1923.45,"would_sl":1921.20,"would_tp":1928.50,"rr":2.27}
{"ts":"2026-05-16T09:42:12Z","event":"trade_open","ticket":12345,"lot":0.05,...}
{"ts":"2026-05-16T11:08:33Z","event":"trade_close","ticket":12345,"r_mult":1.4,"profit_usd":42.10,...}
```
Enables post-mortem + ML-friendly export.

---

## 8. Anti-Curve-Fitting Methodology

### 8.1 Parameter budget (HARD CAPS)
- User-tunable `input`: ≤15 ✅
- Internal constants: ≤15
- Hidden/optimized: **0** in release

### 8.2 Regime-relative thresholds (banned vs allowed)
| Banned | Allowed |
|---|---|
| `MinDisplacement = 30 pts` | `1.5 × ATR(H1)` |
| `MinVolume = 1000` | `Z-score > P80 of last 200` |
| `MaxSpread = 35 pts` | `2 × median(session-matched)` |
| `TPDistance = 200 pts` | `Next liquidity pool, min 2R` |
| `SwingLookback = 5 fixed` | `clamp(ATR_pct/baseline, 3, 8)` |

### 8.3 Release gates (statistical, must ALL pass)
- **WFO**: ≥80% OOS windows pass (PF≥1.20, DD≤12%, N≥25), parameter drift <30%
- **MC**: P5 equity positive, expectancy CI excludes 0, p<0.05 vs random
- **Stress**: PF≥1.10 @ 2×spread, PF≥1.05 @ 5pts slippage
- **Multi-broker**: PF≥1.20 on each of ICMarkets/Darwinex/FTMO independently
- **Stability**: rolling 3-month PF variation <50%, no WR window ±15pp from median

---

## 9. Development Roadmap (35 weeks)

| Phase | Weeks | Effort | Deliverable | Gate |
|---|---|---|---|---|
| 0 — Scaffolding | 1 | 3d | Repo skeleton, STYLE.md, git workflow | Compile clean |
| 1 — Core foundations | 2-3 | 10d | Logger, SymbolMeta, TimeService, BarCache, ATR, basic filters, Persistence, Dashboard skeleton | 5-day demo log clean on 4 brokers |
| 2 — Market structure | 4-5 | 12d | MarketStructure, OB, FVG, Liquidity, Volume, ChartOverlay debug | 20 manual periods, ≥85% swing match; visual trader review pass |
| 3 — Signal engine + dry-run | 6-7 | 12d | ConfluenceScorer, SignalEngine, News pipeline, FilterChain | 30-day dry-run: 0-2 signals/day, manual review accepts ≥80% |
| 4 — Risk + Execution + Backtest | 8-10 | 15d | 3 policies, RiskMgr, OrderRouter, PositionMgr, full backtest 3 brokers × 3 modes × 2018-2024 | PF≥1.20 OOS, zero rule breaches in PROP, all 9 runs pass |
| 5 — Walk-forward | 11 | 5d | WFO Python harness, 36 windows | ≥80% windows pass, drift<30% |
| 6 — Monte Carlo + Stress | 12 | 5d | MC battery, stress tests | All gates §8.3 pass |
| 7 — Demo forward (60-90d) | 13-22 | 30d monitoring | Live demo 3 brokers × 3 modes parallel | Live PF within 30% of backtest, zero crashes |
| **DECISION POINT** | — | — | **Proceed to commercial? If no, fix; if yes, start v2 license** | Live validation pass |
| 8 — Live micro account | 25-29 | 10d | $500-2000 real, PROP mode | 30d clean, no rule violations |
| 9 — Prop firm challenge | 30-32 | 10d | FTMO/MFF $10k+ challenge | Funded |
| 10 — v2 License + Market | 33-35 | 15d | MarketBackend, ServerBackend, MQL5 Market submission, license server deploy, docs | Listed approved, 99.9% server uptime, first customers |

**Total**: ~8 months calendar, ~127 days active effort.

---

## 10. Risks & Mitigations

| # | Risk | Impact | Mitigation |
|---|---|---|---|
| R1 | Broker quotes XAUUSD differently (digits, contract, symbol name) | High | `CSymbolMeta` auto-detect; abort + clear error if non-XAUUSD shape |
| R2 | Broker time ≠ UTC, DST shifts | High | `CTimeService` central; DST table; unit tests on boundary days |
| R3 | EA restart mid-trade | Medium | Idempotent OnInit restores from GV + file; magic-scoped position scan |
| R4 | News XML format change | Medium | Defensive parser; 7-day cache; fail-safe blackout-on |
| R5 | WebRequest disabled by user | Medium | Detect ERR_FUNCTION_NOT_CONFIRMED; dashboard warn; trading halt |
| R6 | Spread spike at NY open / FOMC | High | Dynamic + absolute cap; pre-news blackout |
| R7 | Slippage > expected → DD breach | High | 10% safety pad in CanOpenTrade; OrderRouter slippage abort |
| R8 | Strategy curve-fit | Critical | §8.3 statistical gates mandatory before release |
| R9 | MaxDD permanent kill | Critical/account | Manual unlock token; documented procedure |
| R10 | MQL5 Market rejects (v2) | Medium | Pre-test against validation rules; no DLL, no file outside Files/ |
| R11 | Two EA instances same account | Critical | Init scan; refuse load if magic collision |
| R12 | Account currency ≠ USD | High | `ACCOUNT_CURRENCY` detect; `SYMBOL_TRADE_TICK_VALUE` is account-currency by spec |
| R13 | Weekend gap | High | FridayClose mandatory; design refuses overnight |
| R14 | Decompiled/pirated | Medium | Friction not absolute: Market binding + server JWT + logic masking |

---

## 11. Critical Files for Implementation

1. **`/home/user/FilmaShQIP/FilmaShQIP.mq5`** — entry point ku Phase A→F event-sequence orchestrohet
2. **`/home/user/FilmaShQIP/Include/FilmaShQIP/Risk/RiskManager.mqh`** — by-construction safety; pa këtë gjithçka tjetër s'ka kuptim institucional
3. **`/home/user/FilmaShQIP/Include/FilmaShQIP/Risk/IRiskPolicy.mqh`** + 3 policy files — diferenca midis PROP/CONSERVATIVE/AGGRESSIVE
4. **`/home/user/FilmaShQIP/Include/FilmaShQIP/Signals/MarketStructure.mqh`** — algoritmi më i vështirë (BOS/CHoCH/swings)
5. **`/home/user/FilmaShQIP/Include/FilmaShQIP/Signals/SignalEngine.mqh`** — orchestrator strategjik + ConfluenceScorer
6. **`/home/user/FilmaShQIP/Include/FilmaShQIP/License/ILicenseBackend.mqh`** + `StubBackend.mqh` — interface i vendosur herët për të mbrojtur v2 refactor

---

## 12. Verifikimi End-to-End

### Faza 0-2 (kod-level)
- `MetaEditor → Compile`: 0 errors, 0 warnings, `#property strict`
- Manual code review checklist per modul
- Tests në `Tests/Configs/`: scripts që ngarkojnë `.mqh` dhe printojnë outputs

### Faza 3-4 (backtest)
- Strategy Tester me 99% modelling quality tick data
- Brokers: ICMarkets Raw, Darwinex, FTMO demo
- Periudha: 2018-01 → 2024-12, ku 2023-2024 = PURE OOS
- Matrica: 3 brokers × 3 modes = 9 runs minimum

### Faza 5-6 (statistical)
- Python WFO harness: lexon Strategy Tester report XML, rolling windows
- MC: trade-shuffle 1000×, bootstrap 1000×, permutation 1000×
- Stress: spread×2, slippage+5pts, latency+200ms

### Faza 7 (forward)
- 3 demo brokers paralel, 3 modes paralel = 9 instance running
- Daily log review; weekly summary
- Telegram alerts test on all event types

### Faza 8-9 (live)
- Real micro account → real prop challenge
- Compare live metrics vs demo within ±30% degradation tolerance

### Faza 10 (commercial)
- MQL5 Market validation suite pass
- License server: 99.9% uptime 30 days; JWT signature verify; grace period test
- Documentation review: user manual, quickstart, FAQ

---

## 13. Çfarë e bën KËTË EA institucional (jo retail)

1. **By-construction prop compliance** — JO "hope it stays in DD"; mathematikisht refuzon trade nëse worst-case shkel
2. **Regime-relative everything** — s'ka nevojë re-optimization kur regimi i XAUUSD ndryshon
3. **Statistical release gates** — release vetëm pas WFO+MC+multi-broker; retail ships pas një backtest
4. **3 policies first-class** — interface polimorfik që një prop firm operator mund ta auditojë pa lexuar code spaghetti
5. **Sniper, jo scalper** — 200 trades/year, jo 2000; selektiviteti është edge
6. **Restart idempotency** — institucional desk mund ribootojë VPS pa humbur state
7. **Observable** — çdo vendim (dhe refuzim) i logu me reason; full post-mortem mundësohet
8. **Single-symbol obsession** — JO 28-pair EA "tunable for gold"; çdo konstante është XAUUSD-specifike
9. **Tooling premium** — WFO/MC scripts + Dashboard + Telegram + JSONL journaling që dita 1
10. **Hooks-now-impl-later komerciale** — kursen kompleksitet të kotë nëse strategjia s'kalon FT; refactor i pastër kur të vlejë

---

**End of Blueprint v1.0**
