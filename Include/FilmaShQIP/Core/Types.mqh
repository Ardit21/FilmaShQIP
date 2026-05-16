//+------------------------------------------------------------------+
//|                                                         Types.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: SSwingPoint, SOrderBlock, SFVG, SLiquidityZone,
//|                 SSignal, STradePlan, SClosedTrade, SFilterResult
//| See docs/ARCHITECTURE.md §2.1
//+------------------------------------------------------------------+
#ifndef FSQ_TYPES_MQH
#define FSQ_TYPES_MQH

#property copyright "FilmaShQIP"
#property strict

#include "Defines.mqh"

struct SSwingPoint
  {
   datetime time;
   double   price;
   int      bar_index;
   bool     is_high;
   int      strength;
  };

struct SOrderBlock
  {
   datetime time_open;
   double   high;
   double   low;
   double   open_px;
   double   close_px;
   bool     is_bullish;
   double   displacement;
   bool     has_fvg;
   bool     mitigated;
   int      age_bars;
   int      tf;
  };

struct SFVG
  {
   datetime time;
   double   top;
   double   bottom;
   bool     is_bullish;
   double   size_atr;
   int      age_bars;
   bool     mitigated;
   int      tf;
  };

enum ELiquidityKind
  {
   LIQ_EQH       = 0,
   LIQ_EQL       = 1,
   LIQ_ASIA_HIGH = 2,
   LIQ_ASIA_LOW  = 3,
   LIQ_PDH       = 4,
   LIQ_PDL       = 5,
   LIQ_PWH       = 6,
   LIQ_PWL       = 7
  };

struct SLiquidityZone
  {
   ELiquidityKind kind;
   double         price;
   double         tolerance;
   bool           swept;
   datetime       sweep_time;
  };

struct SSignal
  {
   bool     valid;
   int      direction;
   double   entry;
   double   sl;
   double   tp;
   int      confluence_score;
   string   summary;
   datetime generated_at;
  };

struct STradePlan
  {
   int    direction;
   double entry;
   double sl;
   double tp_partial;
   double tp_runner;
   double lot;
   long   magic;
   string comment;
  };

struct SFilterResult
  {
   bool   passed;
   string reason;
  };

struct SClosedTrade
  {
   ulong    ticket;
   datetime open_time;
   datetime close_time;
   int      direction;
   double   open_price;
   double   close_price;
   double   lot;
   double   profit_usd;
   double   r_multiple;
   string   reason_close;
  };

#endif // FSQ_TYPES_MQH
