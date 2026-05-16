//+------------------------------------------------------------------+
//|                                                  SpreadFilter.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Rolling spread history + dynamic + absolute cap.
//|                 Session-matched bucketing introduced in Phase 3.
//| See docs/ARCHITECTURE.md §5
//+------------------------------------------------------------------+
#ifndef FSQ_SPREADFILTER_MQH
#define FSQ_SPREADFILTER_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"
#include "../Data/SymbolMeta.mqh"
#include "../Utils/Math.mqh"

class CFsqSpreadFilter
  {
private:
   double           m_hist[];
   int              m_idx;
   int              m_count;
   double           m_abs_cap_pts;
   CFsqSymbolMeta  *m_sym;

public:
                     CFsqSpreadFilter()
     {
      m_idx=0; m_count=0; m_abs_cap_pts=50.0; m_sym=NULL;
      ArrayResize(m_hist, K_SPREAD_HIST_LEN);
      for(int i = 0; i < K_SPREAD_HIST_LEN; i++) m_hist[i] = 0.0;
     }

   void              Init(CFsqSymbolMeta *sm, double abs_cap_pts=50.0)
     {
      m_sym = sm;
      m_abs_cap_pts = abs_cap_pts;
      m_idx = 0;
      m_count = 0;
     }

   void              Update()
     {
      if(m_sym == NULL || !m_sym.IsDetected()) return;
      double pts = Current();
      m_hist[m_idx] = pts;
      m_idx = (m_idx + 1) % K_SPREAD_HIST_LEN;
      if(m_count < K_SPREAD_HIST_LEN) m_count++;
     }

   double            Current()
     {
      if(m_sym == NULL) return 0.0;
      string sym = m_sym.Symbol();
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
      double bid = SymbolInfoDouble(sym, SYMBOL_BID);
      double pt  = m_sym.Point();
      if(pt <= 0.0) return 0.0;
      return (ask - bid) / pt;
     }

   double            Median()
     {
      if(m_count <= 0) return 0.0;
      double arr[];
      ArrayResize(arr, m_count);
      for(int i = 0; i < m_count; i++) arr[i] = m_hist[i];
      return CFsqMath::Median(arr, m_count);
     }

   bool              IsAcceptable()
     {
      double cur = Current();
      if(cur > m_abs_cap_pts) return false;
      if(m_count < 30) return cur <= m_abs_cap_pts;
      double med = Median();
      double dyn_cap = MathMax(med * 2.0, med + 5.0);
      return cur <= MathMin(dyn_cap, m_abs_cap_pts);
     }
  };

#endif // FSQ_SPREADFILTER_MQH
