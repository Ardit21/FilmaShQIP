# Changelog

All notable changes to FilmaShQIP will be documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) — semver discipline.

## [Unreleased]

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
