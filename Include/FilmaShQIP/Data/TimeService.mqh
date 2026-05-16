//+------------------------------------------------------------------+
//|                                                   TimeService.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Broker↔UTC↔server time conversions; broker offset
//|                 detection at init; broker-day helpers.
//| See docs/ARCHITECTURE.md §4.1, §R2
//+------------------------------------------------------------------+
#ifndef FSQ_TIMESERVICE_MQH
#define FSQ_TIMESERVICE_MQH

#property copyright "FilmaShQIP"
#property strict

class CFsqTimeService
  {
private:
   int m_broker_offset_sec; // server_time - utc_time

public:
                     CFsqTimeService() { m_broker_offset_sec = 0; }

   bool              Init()
     {
      datetime srv = TimeTradeServer();
      datetime gmt = TimeGMT();
      m_broker_offset_sec = (int)(srv - gmt);
      return true;
     }

   datetime          NowBroker() { return TimeTradeServer(); }
   datetime          NowUTC()    { return TimeGMT(); }
   datetime          NowLocal()  { return TimeLocal(); }

   datetime          BrokerToUTC(datetime b) { return b - m_broker_offset_sec; }
   datetime          UTCToBroker(datetime u) { return u + m_broker_offset_sec; }

   int               BrokerOffsetHours() { return m_broker_offset_sec / 3600; }

   datetime          BrokerDayStart(datetime t)
     {
      MqlDateTime dt;
      TimeToStruct(t, dt);
      dt.hour = 0;
      dt.min  = 0;
      dt.sec  = 0;
      return StructToTime(dt);
     }

   bool              IsSameBrokerDay(datetime a, datetime b)
     {
      return BrokerDayStart(a) == BrokerDayStart(b);
     }

   int               BrokerHour(datetime t)
     {
      MqlDateTime dt;
      TimeToStruct(t, dt);
      return dt.hour;
     }

   int               BrokerDOW(datetime t)
     {
      MqlDateTime dt;
      TimeToStruct(t, dt);
      return dt.day_of_week;
     }

   int               UTCHour(datetime t)
     {
      datetime u = BrokerToUTC(t);
      MqlDateTime dt;
      TimeToStruct(u, dt);
      return dt.hour;
     }
  };

#endif // FSQ_TIMESERVICE_MQH
