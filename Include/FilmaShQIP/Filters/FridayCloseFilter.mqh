//+------------------------------------------------------------------+
//|                                             FridayCloseFilter.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Friday entry block + force-close before weekend.
//|                 Defends against weekend gap risk.
//| See docs/ARCHITECTURE.md §5, §R13
//+------------------------------------------------------------------+
#ifndef FSQ_FRIDAYCLOSEFILTER_MQH
#define FSQ_FRIDAYCLOSEFILTER_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Data/TimeService.mqh"

class CFsqFridayCloseFilter
  {
private:
   CFsqTimeService *m_time;
   int              m_block_hour;
   int              m_close_hour;
   int              m_close_min;

public:
                     CFsqFridayCloseFilter()
     {
      m_time=NULL; m_block_hour=17; m_close_hour=20; m_close_min=0;
     }

   void              Init(CFsqTimeService *ts,
                          int block_hour=17, int close_hour=20, int close_min=0)
     {
      m_time = ts;
      m_block_hour = block_hour;
      m_close_hour = close_hour;
      m_close_min  = close_min;
     }

   bool              BlockNewEntries()
     {
      if(m_time == NULL) return false;
      datetime t = m_time.NowBroker();
      MqlDateTime dt;
      TimeToStruct(t, dt);
      return (dt.day_of_week == 5 && dt.hour >= m_block_hour);
     }

   bool              MustCloseAll()
     {
      if(m_time == NULL) return false;
      datetime t = m_time.NowBroker();
      MqlDateTime dt;
      TimeToStruct(t, dt);
      if(dt.day_of_week != 5) return false;
      if(dt.hour > m_close_hour) return true;
      if(dt.hour == m_close_hour && dt.min >= m_close_min) return true;
      return false;
     }
  };

#endif // FSQ_FRIDAYCLOSEFILTER_MQH
