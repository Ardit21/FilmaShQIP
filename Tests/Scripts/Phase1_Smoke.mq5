//+------------------------------------------------------------------+
//|                                                Phase1_Smoke.mq5  |
//|              FilmaShQIP — Phase 1 smoke test                     |
//|                                                                  |
//| Drag this script onto a XAUUSD chart. It will init the full      |
//| Phase 1 context, exercise every module, print readings to the    |
//| Experts log, then shut down cleanly. Use it to verify on each    |
//| broker that symbol detection, time service, session/spread/      |
//| friday filters, ATR, and journaling all work.                    |
//+------------------------------------------------------------------+
#property copyright "FilmaShQIP"
#property version   "0.1.0"
#property strict
#property script_show_inputs

#include <FilmaShQIP/Core/Context.mqh>

input int    inpMaxSpreadPts = 50;

//+------------------------------------------------------------------+
void OnStart()
  {
   PrintFormat("===== FilmaShQIP Phase 1 Smoke Test (v%s) =====", FSQ_VERSION);

   CFsqContext ctx;
   if(!ctx.Init((double)inpMaxSpreadPts, 17, 20))
     {
      Print("FAIL: context init returned false (check symbol is XAUUSD-shape)");
      return;
     }

   PrintFormat("[Symbol]       %s",  ctx.sym.Describe());
   PrintFormat("[Time]         broker=%s  utc=%s  offset=%dh",
               TimeToString(ctx.time_svc.NowBroker(), TIME_DATE|TIME_SECONDS),
               TimeToString(ctx.time_svc.NowUTC(),    TIME_DATE|TIME_SECONDS),
               ctx.time_svc.BrokerOffsetHours());
   PrintFormat("[Session]      %s",  ctx.sess.Name(ctx.sess.Current()));

   for(int i = 0; i < 5; i++) ctx.spread.Update();
   PrintFormat("[Spread]       current=%.1f pts  median=%.1f pts",
               ctx.spread.Current(), ctx.spread.Median());

   PrintFormat("[ATR]          H1=%.5f  M5=%.5f  M1=%.5f",
               ctx.atr.Value(PERIOD_H1, 1),
               ctx.atr.Value(PERIOD_M5, 1),
               ctx.atr.Value(PERIOD_M1, 1));

   PrintFormat("[Bars]         M5=%d  H1=%d  D1=%d",
               ctx.bars.Bars(PERIOD_M5),
               ctx.bars.Bars(PERIOD_H1),
               ctx.bars.Bars(PERIOD_D1));

   PrintFormat("[Friday]       block_new=%s  close_all=%s",
               ctx.friday.BlockNewEntries() ? "true" : "false",
               ctx.friday.MustCloseAll()    ? "true" : "false");

   PrintFormat("[Account]      #%lld  %s  eq=%.2f  bal=%.2f",
               AccountInfoInteger(ACCOUNT_LOGIN),
               AccountInfoString(ACCOUNT_CURRENCY),
               AccountInfoDouble(ACCOUNT_EQUITY),
               AccountInfoDouble(ACCOUNT_BALANCE));

   ctx.journal.AppendNote("Phase1_Smoke completed");
   ctx.Shutdown();
   Print("===== Smoke test PASSED — see Files/FilmaShQIP/ for JSONL output =====");
  }
//+------------------------------------------------------------------+
