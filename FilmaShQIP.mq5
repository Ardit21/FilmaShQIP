//+------------------------------------------------------------------+
//|                                                    FilmaShQIP.mq5
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
#property copyright "FilmaShQIP"
#property version   "0.1.0"
#property strict
#property description "XAUUSD Institutional EA — Phase 1 foundations (detect/time/session/spread/friday + dashboard)."

#include <FilmaShQIP/Core/Context.mqh>

//---- Inputs (Phase 1 subset; full input set arrives Phase 4)
input int    inpMaxSpreadPts            = 50;   // hard cap on spread (points)
input int    inpFridayBlockHourBroker   = 17;   // no new entries after this broker-hour Friday
input int    inpFridayCloseAllHourBroker= 20;   // close all positions at this broker-hour Friday
input bool   inpEnableDashboard         = true; // show on-chart HUD

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_fsq_ctx = new CFsqContext();
   if(g_fsq_ctx == NULL)
     {
      Print("[FilmaShQIP] FATAL: context allocation failed");
      return INIT_FAILED;
     }
   if(!g_fsq_ctx.Init((double)inpMaxSpreadPts,
                      inpFridayBlockHourBroker,
                      inpFridayCloseAllHourBroker))
     {
      Print("[FilmaShQIP] FATAL: context init failed (likely non-XAUUSD symbol)");
      delete g_fsq_ctx;
      g_fsq_ctx = NULL;
      return INIT_FAILED;
     }
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_fsq_ctx != NULL)
     {
      g_fsq_ctx.Shutdown();
      delete g_fsq_ctx;
      g_fsq_ctx = NULL;
     }
  }

//+------------------------------------------------------------------+
//| Tick — Phase A→F skeleton; only Phase A+B active in Phase 1      |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(g_fsq_ctx == NULL) return;
   g_fsq_ctx.Tick();
   // Phases C (gates), D (signal), E (sizing+exec), F (journal-open)
   // come online progressively in Phases 2..4.
  }

//+------------------------------------------------------------------+
//| Timer (1s) — light periodic tasks                                |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(g_fsq_ctx == NULL) return;
   if(inpEnableDashboard) g_fsq_ctx.Timer();
  }

//+------------------------------------------------------------------+
//| Trade transaction — RegisterTradeResult arrives Phase 4          |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest     &request,
                        const MqlTradeResult      &result)
  {
   // TBD Phase 4
  }
//+------------------------------------------------------------------+
