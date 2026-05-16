//+------------------------------------------------------------------+
//|                                                     Dashboard.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations (skeleton)
//+------------------------------------------------------------------+
//| Responsibility: ChartComment HUD with status of core modules.
//|                 Full strategy data integrated in Phase 3.
//| See docs/ARCHITECTURE.md §7.2
//+------------------------------------------------------------------+
#ifndef FSQ_DASHBOARD_MQH
#define FSQ_DASHBOARD_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"
#include "../Data/SymbolMeta.mqh"
#include "../Data/TimeService.mqh"
#include "../Filters/SessionFilter.mqh"
#include "../Filters/SpreadFilter.mqh"
#include "../Filters/FridayCloseFilter.mqh"

class CFsqDashboard
  {
private:
   CFsqTimeService       *m_time;
   CFsqSymbolMeta        *m_sym;
   CFsqSessionFilter     *m_sess;
   CFsqSpreadFilter      *m_spread;
   CFsqFridayCloseFilter *m_friday;
   datetime               m_last_render;

public:
                     CFsqDashboard()
     {
      m_time=NULL; m_sym=NULL; m_sess=NULL; m_spread=NULL; m_friday=NULL;
      m_last_render=0;
     }

   void              Init(CFsqTimeService *ts, CFsqSymbolMeta *sm,
                          CFsqSessionFilter *sf, CFsqSpreadFilter *sp,
                          CFsqFridayCloseFilter *fc)
     {
      m_time   = ts;
      m_sym    = sm;
      m_sess   = sf;
      m_spread = sp;
      m_friday = fc;
     }

   void              Render()
     {
      datetime now = TimeCurrent();
      if(now - m_last_render < 1) return;
      m_last_render = now;

      string  sym_str    = (m_sym  != NULL ? m_sym.Symbol()       : "?");
      int     digits     = (m_sym  != NULL ? m_sym.Digits()       : 0);
      double  contract   = (m_sym  != NULL ? m_sym.ContractSize() : 0.0);
      string  sess_name  = (m_sess != NULL ? m_sess.Name(m_sess.Current()) : "?");
      double  spread_cur = (m_spread != NULL ? m_spread.Current() : 0.0);
      double  spread_med = (m_spread != NULL ? m_spread.Median()  : 0.0);
      string  friday_st  = "OK";
      if(m_friday != NULL)
        {
         if(m_friday.MustCloseAll())       friday_st = "CLOSE-ALL";
         else if(m_friday.BlockNewEntries()) friday_st = "BLOCK-NEW";
        }
      int     ofs_hrs    = (m_time != NULL ? m_time.BrokerOffsetHours() : 0);

      double  eq  = AccountInfoDouble(ACCOUNT_EQUITY);
      double  bal = AccountInfoDouble(ACCOUNT_BALANCE);
      string  ccy = AccountInfoString(ACCOUNT_CURRENCY);
      long    acc = AccountInfoInteger(ACCOUNT_LOGIN);

      string out = StringFormat(
         "══════════════════════════════════════════════\n"
         "  FilmaShQIP v%s   |   Phase 1 — Foundations\n"
         "══════════════════════════════════════════════\n"
         "  Symbol:   %s  (digits=%d  contract=%.0f)\n"
         "  Broker:   offset=%d h vs UTC\n"
         "  Session:  %s\n"
         "  Spread:   %.1f pts   (median %.1f)\n"
         "  Friday:   %s\n"
         "  Account:  #%lld  (%s)\n"
         "  Equity:   %.2f       Balance: %.2f\n"
         "══════════════════════════════════════════════",
         FSQ_VERSION,
         sym_str, digits, contract,
         ofs_hrs,
         sess_name,
         spread_cur, spread_med,
         friday_st,
         acc, ccy,
         eq, bal);

      Comment(out);
     }

   void              Clear() { Comment(""); }
  };

#endif // FSQ_DASHBOARD_MQH
