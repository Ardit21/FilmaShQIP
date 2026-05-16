//+------------------------------------------------------------------+
//|                                                       Context.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Runtime singleton — owns and wires together every
//|                 module instance. Other code reaches modules via
//|                 the global FsqCtx() accessor.
//| See docs/ARCHITECTURE.md §1.4
//+------------------------------------------------------------------+
#ifndef FSQ_CONTEXT_MQH
#define FSQ_CONTEXT_MQH

#property copyright "FilmaShQIP"
#property strict

#include "Defines.mqh"
#include "Types.mqh"
#include "Errors.mqh"
#include "../Utils/Math.mqh"
#include "../Utils/String.mqh"
#include "../Utils/Persistence.mqh"
#include "../Logger/Logger.mqh"
#include "../Logger/TradeJournal.mqh"
#include "../Data/SymbolMeta.mqh"
#include "../Data/TimeService.mqh"
#include "../Data/BarCache.mqh"
#include "../Data/ATR.mqh"
#include "../Filters/SessionFilter.mqh"
#include "../Filters/SpreadFilter.mqh"
#include "../Filters/FridayCloseFilter.mqh"
#include "../UI/Dashboard.mqh"

class CFsqContext
  {
public:
   CFsqLogger             logger;
   CFsqTradeJournal       journal;
   CFsqSymbolMeta         sym;
   CFsqTimeService        time_svc;
   CFsqBarCache           bars;
   CFsqATR                atr;
   CFsqSessionFilter      sess;
   CFsqSpreadFilter       spread;
   CFsqFridayCloseFilter  friday;
   CFsqDashboard          dashboard;

   bool              Init(double max_spread_pts = 50.0,
                          int    friday_block_hour = 17,
                          int    friday_close_hour = 20)
     {
      logger.Init(LOG_INFO, "FSQ");
      logger.Info(StringFormat("FilmaShQIP v%s — Phase 1 init begin", FSQ_VERSION));

      if(!sym.Detect())
        {
         logger.Fatal("Symbol detection failed; expected XAUUSD-shape");
         return false;
        }
      logger.Info("Symbol detected: " + sym.Describe());

      time_svc.Init();
      logger.Info(StringFormat("Broker offset = %d hours vs UTC", time_svc.BrokerOffsetHours()));

      bars.Init();
      atr.Init(K_ATR_PERIOD);

      sess.Init(GetPointer(time_svc));
      spread.Init(GetPointer(sym), max_spread_pts);
      friday.Init(GetPointer(time_svc), friday_block_hour, friday_close_hour, 0);

      journal.Init(GetPointer(logger));
      journal.AppendNote(StringFormat("Phase 1 init on account %lld / broker %s",
                                       AccountInfoInteger(ACCOUNT_LOGIN),
                                       AccountInfoString(ACCOUNT_COMPANY)));

      dashboard.Init(GetPointer(time_svc), GetPointer(sym),
                     GetPointer(sess),     GetPointer(spread),
                     GetPointer(friday));

      logger.Info("Phase 1 init complete");
      return true;
     }

   void              Tick()
     {
      spread.Update();
     }

   void              Timer()
     {
      dashboard.Render();
     }

   void              Shutdown()
     {
      logger.Info("Shutdown");
      dashboard.Clear();
     }
  };

CFsqContext *g_fsq_ctx = NULL;

CFsqContext *FsqCtx() { return g_fsq_ctx; }

#endif // FSQ_CONTEXT_MQH
