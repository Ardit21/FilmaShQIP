//+------------------------------------------------------------------+
//|                                                   Persistence.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: GlobalVariables (numeric) + Files/ (text) dual store
//| See docs/ARCHITECTURE.md §1.6
//+------------------------------------------------------------------+
#ifndef FSQ_PERSISTENCE_MQH
#define FSQ_PERSISTENCE_MQH

#property copyright "FilmaShQIP"
#property strict

#include "../Core/Defines.mqh"

class CFsqPersistence
  {
public:
   static bool SaveDouble(string key, double val)
     {
      return GlobalVariableSet(key, val) > 0;
     }

   static bool LoadDouble(string key, double &out, double dflt = 0.0)
     {
      if(GlobalVariableCheck(key))
        {
         out = GlobalVariableGet(key);
         return true;
        }
      out = dflt;
      return false;
     }

   static bool SaveLong(string key, long val)
     {
      return GlobalVariableSet(key, (double)val) > 0;
     }

   static bool LoadLong(string key, long &out, long dflt = 0)
     {
      if(GlobalVariableCheck(key))
        {
         out = (long)GlobalVariableGet(key);
         return true;
        }
      out = dflt;
      return false;
     }

   static bool SaveBool(string key, bool val)
     {
      return GlobalVariableSet(key, val ? 1.0 : 0.0) > 0;
     }

   static bool LoadBool(string key, bool &out, bool dflt = false)
     {
      if(GlobalVariableCheck(key))
        {
         out = GlobalVariableGet(key) > 0.5;
         return true;
        }
      out = dflt;
      return false;
     }

   static bool Delete(string key)
     {
      return GlobalVariableDel(key);
     }

   static string SubdirPath(string filename)
     {
      return FSQ_FILES_SUBDIR + "\\" + filename;
     }

   static bool SaveText(string filename, string content)
     {
      string path = SubdirPath(filename);
      int h = FileOpen(path, FILE_WRITE|FILE_TXT|FILE_ANSI);
      if(h == INVALID_HANDLE) return false;
      FileWriteString(h, content);
      FileClose(h);
      return true;
     }

   static bool LoadText(string filename, string &out)
     {
      string path = SubdirPath(filename);
      if(!FileIsExist(path)) return false;
      int h = FileOpen(path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
      if(h == INVALID_HANDLE) return false;
      out = "";
      while(!FileIsEnding(h))
         out += FileReadString(h) + "\n";
      FileClose(h);
      return true;
     }
  };

#endif // FSQ_PERSISTENCE_MQH
