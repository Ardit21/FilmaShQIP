//+------------------------------------------------------------------+
//|                                                 SessionFilter.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: London / NY / Overlap detection in UTC. Asia is
//|                 reference-only (we don't trade Asia for XAUUSD).
//| See docs/ARCHITECTURE.md §5
//+------------------------------------------------------------------+
#ifndef FSQ_SESSIONFILTER_MQH
#define FSQ_SESSIONFILTER_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"
#include "../Data/TimeService.mqh"

class CFsqSessionFilter
  {
private:
   int               m_london_start_utc;
   int               m_london_end_utc;
   int               m_ny_start_utc;
   int               m_ny_end_utc;
   CFsqTimeService  *m_time;

public:
                     CFsqSessionFilter()
     {
      m_london_start_utc=7; m_london_end_utc=15;
      m_ny_start_utc=12;    m_ny_end_utc=20;
      m_time=NULL;
     }

   void              Init(CFsqTimeService *ts,
                          int london_start=7, int london_end=15,
                          int ny_start=12,    int ny_end=20)
     {
      m_time = ts;
      m_london_start_utc = london_start;
      m_london_end_utc   = london_end;
      m_ny_start_utc     = ny_start;
      m_ny_end_utc       = ny_end;
     }

   ESession          Current()
     {
      if(m_time == NULL) return SESS_NONE;
      datetime u = m_time.NowUTC();
      MqlDateTime dt;
      TimeToStruct(u, dt);
      int h = dt.hour;
      bool in_lon = (h >= m_london_start_utc && h < m_london_end_utc);
      bool in_ny  = (h >= m_ny_start_utc     && h < m_ny_end_utc);
      if(in_lon && in_ny) return SESS_OVERLAP;
      if(in_lon)          return SESS_LONDON;
      if(in_ny)           return SESS_NY;
      if(h >= 22 || h < 7) return SESS_ASIA;
      return SESS_NONE;
     }

   bool              IsInWindow()
     {
      ESession s = Current();
      return s == SESS_LONDON || s == SESS_NY || s == SESS_OVERLAP;
     }

   bool              IsOverlap() { return Current() == SESS_OVERLAP; }

   string            Name(ESession s)
     {
      switch(s)
        {
         case SESS_ASIA:    return "ASIA";
         case SESS_LONDON:  return "LONDON";
         case SESS_NY:      return "NY";
         case SESS_OVERLAP: return "OVERLAP";
        }
      return "NONE";
     }
  };

#endif // FSQ_SESSIONFILTER_MQH
