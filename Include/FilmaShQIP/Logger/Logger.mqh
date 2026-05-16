//+------------------------------------------------------------------+
//|                                                        Logger.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Leveled logging (Debug..Fatal); writes JSONL to
//|                 Files/FilmaShQIP/log_YYYYMMDD.jsonl + Experts log.
//| See docs/ARCHITECTURE.md §7.4
//+------------------------------------------------------------------+
#ifndef FSQ_LOGGER_MQH
#define FSQ_LOGGER_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"
#include "../Utils/String.mqh"

class CFsqLogger
  {
private:
   ELogLevel m_min_level;
   string    m_module;
   int       m_handle;
   datetime  m_file_date;

   string FilenameForToday()
     {
      MqlDateTime t;
      TimeToStruct(TimeCurrent(), t);
      return StringFormat("%s\\%s%04d%02d%02d.jsonl",
                          FSQ_FILES_SUBDIR, K_FILE_LOG_PREFIX, t.year, t.mon, t.day);
     }

   void RotateIfNeeded()
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
      RotateIfNeeded();
      if(m_handle != INVALID_HANDLE) return true;
      string fn = FilenameForToday();
      m_handle = FileOpen(fn, FILE_WRITE|FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
      if(m_handle == INVALID_HANDLE) return false;
      FileSeek(m_handle, 0, SEEK_END);
      return true;
     }

   string LevelName(ELogLevel lvl)
     {
      switch(lvl)
        {
         case LOG_DEBUG: return "DEBUG";
         case LOG_INFO:  return "INFO";
         case LOG_WARN:  return "WARN";
         case LOG_ERROR: return "ERROR";
         case LOG_FATAL: return "FATAL";
        }
      return "?";
     }

public:
                     CFsqLogger() { m_min_level=LOG_INFO; m_module="FSQ"; m_handle=INVALID_HANDLE; m_file_date=0; }
                    ~CFsqLogger() { if(m_handle != INVALID_HANDLE) FileClose(m_handle); }

   void              Init(ELogLevel min_lvl, string module_name)
     {
      m_min_level = min_lvl;
      m_module    = module_name;
     }

   void              SetLevel(ELogLevel lvl) { m_min_level = lvl; }
   ELogLevel         Level() { return m_min_level; }

   void              Log(ELogLevel lvl, string msg)
     {
      if(lvl < m_min_level) return;

      string lvl_name = LevelName(lvl);
      string ts = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      string line = StringFormat("[%s] %s: %s", m_module, lvl_name, msg);

      if(lvl >= LOG_ERROR)      Print("[FSQ-ERR] ",  line);
      else if(lvl == LOG_WARN)  Print("[FSQ-WARN] ", line);
      else                      Print("[FSQ] ",      line);

      if(!EnsureOpen()) return;
      string json = StringFormat("{\"ts\":\"%s\",\"lvl\":\"%s\",\"mod\":\"%s\",\"msg\":\"%s\"}",
                                  ts, lvl_name, m_module, CFsqString::JsonEscape(msg));
      FileWriteString(m_handle, json + "\n");
      FileFlush(m_handle);
     }

   void              Debug(string m) { Log(LOG_DEBUG, m); }
   void              Info(string m)  { Log(LOG_INFO,  m); }
   void              Warn(string m)  { Log(LOG_WARN,  m); }
   void              Error(string m) { Log(LOG_ERROR, m); }
   void              Fatal(string m) { Log(LOG_FATAL, m); }
  };

#endif // FSQ_LOGGER_MQH
