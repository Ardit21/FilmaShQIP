# Changelog

All notable changes to FilmaShQIP will be documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) — semver discipline.

## [Unreleased]

### Phase 1 — Core Foundations (2026-05-16)

#### Added — implementations
- `Core/Defines.mqh` — version, GV keys, file names, enums (EPolicyMode,
  ESession, ENewsImpact, ELogLevel, EAnchorKind), regime-relative constants
- `Core/Types.mqh` — SSwingPoint, SOrderBlock, SFVG, SLiquidityZone,
  ELiquidityKind, SSignal, STradePlan, SFilterResult, SClosedTrade
- `Core/Errors.mqh` — TRADE_RETCODE retriability + descriptions
- `Utils/Math.mqh` — Clamp, Mean, StdDev, ZScore, Percentile, Median
- `Utils/String.mqh` — FormatLot/Price/R/Pct/USD + JsonEscape
- `Utils/Persistence.mqh` — GlobalVariables (double/long/bool) +
  Files/ text I/O under FSQ_FILES_SUBDIR
- `Logger/Logger.mqh` — 5-level logger, JSONL daily rotation, mirrors to Experts log
- `Logger/TradeJournal.mqh` — JSONL events: signal/open/close/reject/kill/note
- `Data/SymbolMeta.mqh` — XAUUSD auto-detection across brokers
  (GOLD/XAUUSD/XAU/USD variants), digits/contract/lot bounds sanity check
- `Data/TimeService.mqh` — broker offset detection at init, UTC↔broker conversions,
  broker-day helpers
- `Data/BarCache.mqh` — multi-TF new-bar detection + OHLCV/volume accessors
- `Data/ATR.mqh` — rolling ATR per TF, last-closed-bar default (no peek)
- `Filters/SessionFilter.mqh` — London/NY/Overlap/Asia classification in UTC
- `Filters/SpreadFilter.mqh` — rolling history (300 samples) + dynamic
  and absolute caps
- `Filters/FridayCloseFilter.mqh` — broker-hour block + force-close
- `UI/Dashboard.mqh` — ChartComment HUD wired to Phase 1 modules
- `Core/Context.mqh` — singleton with all module instances + global accessor
- `FilmaShQIP.mq5` — updated entry: Init/Tick/Timer/Deinit wired through Context,
  4 inputs (MaxSpreadPts, FridayBlockHour, FridayCloseHour, EnableDashboard)
- `Tests/Scripts/Phase1_Smoke.mq5` — drag-on-chart smoke test that
  exercises every Phase 1 module and prints readings

#### Notes
- All thresholds remain regime-relative (ATR multiples) per anti-curve-fit rules
- Daily JSONL files rotate automatically under Files/FilmaShQIP/
- Default broker symbol is auto-detected; non-XAUUSD shapes abort Init with FATAL

#### Next (Phase 2 — Market Structure Engine, 2 weeks)
- MarketStructure (swings, BOS, CHoCH, Premium/Discount)
- OrderBlocks scanner with displacement + FVG confirmation
- FVG tracker (detect, age, mitigate)
- LiquidityScanner (EQH/EQL, Asia H/L, PDH/L, PWH/L, sweep detection)
- VolumeAnalyzer (tick-vol z-score, absorption, exhaustion)
- ChartOverlay debug mode for visual validation

### Phase 0 — Scaffolding (2026-05-16)

#### Added
- Repository skeleton per `docs/ARCHITECTURE.md` §2
- `docs/ARCHITECTURE.md` — full v1.0 architectural blueprint
- `STYLE.md` — coding conventions
- `README.md` — project summary
- Directory tree for `Include/FilmaShQIP/{Core,Data,Signals,Risk,Execution,Filters,News,License,Logger,Alerts,UI,Utils}`
- Directory tree for `Tests/{WFO,MonteCarlo,Reports,Configs}`
- Empty `.mqh` stub files with include guards and header comments
- `FilmaShQIP.mq5` entry point with empty event handlers (compile-clean)
- `.gitignore` for MetaTrader compiled artifacts

#### Notes
- Branch: `claude/gold-ea-blueprint-8AJ3z`
- Approved refinements integrated:
  - 3 risk presets (PROP / CONSERVATIVE / AGGRESSIVE)
  - License = hooks/interface only in v1; full impl post Phase 7 Forward Test
  - All 4 tooling pillars planned (WFO+MC scripts, Dashboard HUD, Telegram/Email, JSONL journaling)

#### Next (Phase 1 — Core Foundations, 2 weeks)
- Implement `Logger`, `TradeJournal`, `SymbolMeta`, `TimeService`, `BarCache`, `ATR`
- Implement `SessionFilter`, `SpreadFilter`, `FridayCloseFilter`, `Persistence`
- 5-day demo log clean across ICMarkets / Darwinex / Pepperstone / FTMO demo
