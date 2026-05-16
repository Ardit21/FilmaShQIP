//+------------------------------------------------------------------+
//|                                                  FilmaShQIP.mq5  |
//|                  FilmaShQIP — XAUUSD Institutional EA            |
//|                       Phase 0 scaffolding (empty stubs)          |
//+------------------------------------------------------------------+
#property copyright "FilmaShQIP"
#property version   "0.1.0"
#property strict
#property description "XAUUSD Institutional EA — Phase 0 scaffolding. See docs/ARCHITECTURE.md."

// Phase 0: includes commented out until modules are implemented.
// Uncomment progressively per phase per docs/ARCHITECTURE.md §9.
// #include <FilmaShQIP/Core/Context.mqh>

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("[FilmaShQIP] OnInit — Phase 0 scaffolding (no strategy logic loaded)");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("[FilmaShQIP] OnDeinit — reason=", reason);
}

//+------------------------------------------------------------------+
//| Expert tick handler — Phase A→F per docs/ARCHITECTURE.md §1.4    |
//+------------------------------------------------------------------+
void OnTick()
{
    // Phase A: Data refresh   — TBD Phase 1
    // Phase B: State maintain — TBD Phase 4
    // Phase C: Pre-trade gates — TBD Phase 3
    // Phase D: Signal eval     — TBD Phase 3
    // Phase E: Sizing + exec   — TBD Phase 4
    // Phase F: Journaling      — TBD Phase 1
}

//+------------------------------------------------------------------+
//| Timer — periodic light tasks                                     |
//+------------------------------------------------------------------+
void OnTimer()
{
    // News refresh, license heartbeat, dashboard render — TBD
}

//+------------------------------------------------------------------+
//| Trade transaction — trade lifecycle hooks                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest     &request,
                        const MqlTradeResult      &result)
{
    // Register trade results, update loss-streak, journal close — TBD
}
//+------------------------------------------------------------------+
