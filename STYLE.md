# FilmaShQIP — Coding Style Guide

## File layout

- Entry: `FilmaShQIP.mq5` — event handlers only, max ~150 LOC
- Includes: `Include/FilmaShQIP/<Group>/<Module>.mqh`
- One class per `.mqh` file (with rare exceptions for tightly-coupled small helpers)
- Include guards: `#ifndef FSQ_<MODULE>_MQH` ... `#define FSQ_<MODULE>_MQH` ... `#endif`

## Naming

| Kind | Prefix / Style | Example |
|---|---|---|
| Class | `C` | `CRiskManager`, `CSignalEngine` |
| Interface | `I` | `IRiskPolicy`, `IAlertSink` |
| Struct | `S` | `SSwingPoint`, `STradePlan` |
| Enum | `E` | `EPolicyMode`, `ESession` |
| Member variable | `m_` | `m_peak_equity` |
| Input variable | `inp` | `inpRiskPctOverride` |
| Constant (#define) | `K_` | `K_FVG_MIN_SIZE` |
| Local variable | snake_case | `sl_distance`, `tick_value` |
| Function | PascalCase | `CalcLotSize`, `CanOpenTrade` |
| Macro internal | `FSQ_` | `FSQ_VERSION` |

## Formatting

- Indent: 4 spaces (NO tabs)
- Max line width: 120 chars
- Opening brace on same line for functions, on new line for class bodies (MQL5 convention)
- One blank line between methods; two between class definitions
- Always brace single-line `if`/`for`/`while` bodies

## Comments

- Default: no comments. Code should be self-documenting via naming.
- Only comment WHY when it's non-obvious: hidden constraint, broker quirk, regime assumption, anti-curve-fit rationale.
- Never comment WHAT — that's what code is for.
- File-level header allowed:

```mql5
//+------------------------------------------------------------------+
//|                                            RiskManager.mqh        |
//|              FilmaShQIP — XAUUSD Institutional EA                 |
//|              By-construction prop-firm compliance                 |
//+------------------------------------------------------------------+
```

## MQL5-specific rules

- ALL files: `#property strict` (where applicable for .mq5)
- Use `CObject`-derived classes for stateful modules → enables `CArrayObj` collections
- Pure helpers: namespace-style static functions in `Utils/`
- Interfaces: abstract classes with `virtual` pure methods
- NEVER use `MathRand()` for trade decisions (only `#ifdef DEBUG` for tests)
- NEVER use DLL imports (MQL5 Market compliance)
- NEVER write files outside `Files/FilmaShQIP/` subtree
- Always check `WebRequest` return value; `-1` + `ERR_FUNCTION_NOT_CONFIRMED` → block trading, warn user

## Anti-curve-fit rules (CRITICAL)

- ZERO hardcoded thresholds in pips / USD / points
- All thresholds: ATR-normalized, percentile-based, or session-relative
- User inputs ≤ 15 (enforced at code-review time)
- Internal constants ≤ 15
- Hidden/optimized "magic numbers" in release: ZERO

## Git workflow

- `main`: production-ready releases only (tagged semver)
- `develop`: integration branch
- `feat/<module>`: feature branches, squash-merged into develop
- `claude/<task-name>`: AI-assisted work branches
- Commit messages: imperative mood, present tense, ≤72 chars subject

## Review checklist (before merge)

- [ ] Compiles 0 errors, 0 warnings under MetaEditor strict
- [ ] No magic numbers in pips/USD
- [ ] Inputs not exceeding budget
- [ ] All `WebRequest` calls fail-safe (assume worst case on error)
- [ ] All persistent state has GV + file dual-write
- [ ] All trade-affecting decisions logged via `CLogger` with reason
- [ ] `OnTick` is idempotent (same state + tick → same outcome)
