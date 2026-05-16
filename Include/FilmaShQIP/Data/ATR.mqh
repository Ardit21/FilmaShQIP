//+------------------------------------------------------------------+
//|                                                           ATR.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: ATR computation per TF. Used by every regime-relative
//|                 threshold in the strategy. Percentile bands deferred
//|                 to Phase 2.
//| See docs/ARCHITECTURE.md §1.5.2
//+------------------------------------------------------------------+
#ifndef FSQ_ATR_MQH
#define FSQ_ATR_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"

class CFsqATR
  {
private:
   int m_period;

public:
                     CFsqATR() { m_period = K_ATR_PERIOD; }

   bool              Init(int period = K_ATR_PERIOD)
     {
      m_period = period;
      return true;
     }

   // ATR on last *closed* bar by default (shift=1). Never peek at shift=0.
   double            Value(ENUM_TIMEFRAMES tf, int shift = 1)
     {
      if(shift < 1) shift = 1;
      double tr_sum = 0.0;
      for(int i = shift; i < shift + m_period; i++)
        {
         double h  = iHigh(_Symbol, tf, i);
         double l  = iLow(_Symbol, tf, i);
         double c1 = iClose(_Symbol, tf, i + 1);
         double tr = MathMax(h - l, MathMax(MathAbs(h - c1), MathAbs(l - c1)));
         tr_sum += tr;
        }
      return tr_sum / m_period;
     }
  };

#endif // FSQ_ATR_MQH
