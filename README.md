# FilmaShQIP — XAUUSD Institutional Expert Advisor

**Status**: Phase 0 — Scaffolding (no executable strategy yet)
**Symbol**: XAUUSD only
**Platform**: MetaTrader 5 (MQL5)
**Branch**: `claude/gold-ea-blueprint-8AJ3z`

## What this is

An institutional-grade Expert Advisor for XAUUSD built on a hybrid SMC + Price Action + Volume framework, with by-construction prop-firm compliance, 3 risk presets (PROP / CONSERVATIVE / AGGRESSIVE), and statistical anti-curve-fit guardrails (walk-forward, Monte Carlo, multi-broker validation).

## What this is NOT

- Not a multi-symbol EA
- Not a scalper (target: 0–2 A+ trades/day)
- Not an indicator-based system
- Not a martingale or grid system

## Documentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — full architectural blueprint
- [`STYLE.md`](STYLE.md) — coding conventions
- [`CHANGELOG.md`](CHANGELOG.md) — version history

## Build

Open `FilmaShQIP.mq5` in MetaEditor 5 → F7. Phase 0 builds compile-clean as empty stubs.

## License

Proprietary. All rights reserved.
