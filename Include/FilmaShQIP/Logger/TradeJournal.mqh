//+------------------------------------------------------------------+
//|                                                  TradeJournal.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: JSONL append for signal/open/close/reject/kill.
//|                 One file per day under Files/FilmaShQIP/.
//| See docs/ARCHITECTURE.md §7.4
//+------------------------------------------------------------------+
#ifndef FSQ_TRADEJOURNAL_MQH
#define FSQ_TRADEJOURNAL_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"
#include "../Core/Types.mqh"
#include "../Utils/String.mqh"
#include "Logger.mqh"

class CFsqTradeJournal
  {
private:
   CFsqLogger *m_logger;
   int         m_handle;
   datetime    m_file_date;

   string FilenameForToday()
     {
      MqlDateTime t;
      TimeToStruct(TimeCurrent(), t);
      return StringFormat("%s\\%s%04d%02d%02d.jsonl",
                          FSQ_FILES_SUBDIR, K_FILE_JOURNAL_PRX, t.year, t.mon, t.day);
     }

   void Rotate()
     {
      datetime today = (TimeCurrent() / 86400) * 86400;
      if(today != m_file_date)
        {
         if(m_handle != INVALID_HANDLE) { FileClose(m_handle); m_handle = INVALID_HANDLE; }
         m_file_date = today;
        }
     }

   bool EnsureOpen()
     {
      Rotate();
      if(m_handle != INVALID_HANDLE) return true;
      m_handle = FileOpen(FilenameForToday(),
                          FILE_WRITE|FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
      if(m_handle == INVALID_HANDLE) return false;
      FileSeek(m_handle, 0, SEEK_END);
      return true;
     }

   void WriteLine(string json)
     {
      if(!EnsureOpen())
        {
         if(m_logger != NULL) m_logger.Warn("TradeJournal: file open failed");
         return;
        }
      FileWriteString(m_handle, json + "\n");
      FileFlush(m_handle);
     }

public:
                     CFsqTradeJournal() { m_logger=NULL; m_handle=INVALID_HANDLE; m_file_date=0; }
                    ~CFsqTradeJournal() { if(m_handle != INVALID_HANDLE) FileClose(m_handle); }

   void              Init(CFsqLogger *logger) { m_logger = logger; }

   void              AppendSignal(const SSignal &sig)
     {
      string ts = TimeToString(sig.generated_at, TIME_DATE|TIME_SECONDS);
      string json = StringFormat(
         "{\"ts\":\"%s\",\"event\":\"signal\",\"dir\":%d,\"score\":%d,"
         "\"entry\":%.2f,\"sl\":%.2f,\"tp\":%.2f,\"summary\":\"%s\"}",
         ts, sig.direction, sig.confluence_score,
         sig.entry, sig.sl, sig.tp,
         CFsqString::JsonEscape(sig.summary));
      WriteLine(json);
     }

   void              AppendOpen(ulong ticket, const STradePlan &plan)
     {
      string ts = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      string json = StringFormat(
         "{\"ts\":\"%s\",\"event\":\"trade_open\",\"ticket\":%llu,"
         "\"dir\":%d,\"lot\":%.2f,\"entry\":%.2f,\"sl\":%.2f,\"tp\":%.2f,\"magic\":%lld}",
         ts, ticket, plan.direction, plan.lot,
         plan.entry, plan.sl, plan.tp_partial, plan.magic);
      WriteLine(json);
     }

   void              AppendClose(const SClosedTrade &t)
     {
      string ots = TimeToString(t.open_time, TIME_DATE|TIME_SECONDS);
      string cts = TimeToString(t.close_time, TIME_DATE|TIME_SECONDS);
      string json = StringFormat(
         "{\"ts\":\"%s\",\"event\":\"trade_close\",\"ticket\":%llu,"
         "\"open_ts\":\"%s\",\"dir\":%d,\"open\":%.2f,\"close\":%.2f,"
         "\"lot\":%.2f,\"profit\":%.2f,\"r_mult\":%.2f,\"reason\":\"%s\"}",
         cts, t.ticket, ots, t.direction,
         t.open_price, t.close_price, t.lot,
         t.profit_usd, t.r_multiple,
         CFsqString::JsonEscape(t.reason_close));
      WriteLine(json);
     }

   void              AppendReject(string reason)
     {
      string ts = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      string json = StringFormat("{\"ts\":\"%s\",\"event\":\"reject\",\"reason\":\"%s\"}",
                                  ts, CFsqString::JsonEscape(reason));
      WriteLine(json);
     }

   void              AppendKill(string reason, bool permanent)
     {
      string ts = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      string json = StringFormat(
         "{\"ts\":\"%s\",\"event\":\"kill_switch\",\"reason\":\"%s\",\"permanent\":%s}",
         ts, CFsqString::JsonEscape(reason), permanent ? "true" : "false");
      WriteLine(json);
     }

   void              AppendNote(string note)
     {
      string ts = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      string json = StringFormat("{\"ts\":\"%s\",\"event\":\"note\",\"msg\":\"%s\"}",
                                  ts, CFsqString::JsonEscape(note));
      WriteLine(json);
     }
  };

#endif // FSQ_TRADEJOURNAL_MQH
