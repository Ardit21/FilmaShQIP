//+------------------------------------------------------------------+
//|                                                      BarCache.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: New-bar detection per TF + thin OHLCV accessors.
//|                 Phase 1 is a pass-through to iHigh/iLow/iClose etc;
//|                 full caching introduced in Phase 2 if needed.
//| See docs/ARCHITECTURE.md §1.4 Phase A
//+------------------------------------------------------------------+
#ifndef FSQ_BARCACHE_MQH
#define FSQ_BARCACHE_MQH

#property copyright "FilmaShQIP"
#property strict

class CFsqBarCache
  {
private:
   datetime m_last_bar_time[7]; // M1,M5,M15,M30,H1,H4,D1

   int               TFIndex(ENUM_TIMEFRAMES tf)
     {
      switch(tf)
        {
         case PERIOD_M1:  return 0;
         case PERIOD_M5:  return 1;
         case PERIOD_M15: return 2;
         case PERIOD_M30: return 3;
         case PERIOD_H1:  return 4;
         case PERIOD_H4:  return 5;
         case PERIOD_D1:  return 6;
        }
      return -1;
     }

public:
                     CFsqBarCache()
     {
      for(int i = 0; i < 7; i++) m_last_bar_time[i] = 0;
     }

   bool              Init() { return true; }

   bool              IsNewBar(ENUM_TIMEFRAMES tf)
     {
      int idx = TFIndex(tf);
      if(idx < 0) return false;
      datetime t = iTime(_Symbol, tf, 0);
      if(t != m_last_bar_time[idx])
        {
         m_last_bar_time[idx] = t;
         return true;
        }
      return false;
     }

   double            High(ENUM_TIMEFRAMES tf, int shift)   { return iHigh(_Symbol, tf, shift); }
   double            Low(ENUM_TIMEFRAMES tf, int shift)    { return iLow(_Symbol, tf, shift); }
   double            Open(ENUM_TIMEFRAMES tf, int shift)   { return iOpen(_Symbol, tf, shift); }
   double            Close(ENUM_TIMEFRAMES tf, int shift)  { return iClose(_Symbol, tf, shift); }
   datetime          Time(ENUM_TIMEFRAMES tf, int shift)   { return iTime(_Symbol, tf, shift); }
   long              Volume(ENUM_TIMEFRAMES tf, int shift) { return iVolume(_Symbol, tf, shift); }
   int               Bars(ENUM_TIMEFRAMES tf)              { return iBars(_Symbol, tf); }
  };

#endif // FSQ_BARCACHE_MQH
