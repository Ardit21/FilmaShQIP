//+------------------------------------------------------------------+
//|                                                        Errors.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Error codes, retry policies, fail-safe defaults
//| See docs/ARCHITECTURE.md §1.4
//+------------------------------------------------------------------+
#ifndef FSQ_ERRORS_MQH
#define FSQ_ERRORS_MQH

#property copyright "FilmaShQIP"
#property strict

class CFsqErrors
  {
public:
   static bool IsRetriable(int code)
     {
      switch(code)
        {
         case TRADE_RETCODE_REQUOTE:
         case TRADE_RETCODE_PRICE_OFF:
         case TRADE_RETCODE_PRICE_CHANGED:
         case TRADE_RETCODE_TIMEOUT:
         case TRADE_RETCODE_CONNECTION:
            return true;
         default:
            return false;
        }
     }

   static string DescribeTrade(int code)
     {
      switch(code)
        {
         case TRADE_RETCODE_DONE:           return "DONE";
         case TRADE_RETCODE_REQUOTE:        return "REQUOTE";
         case TRADE_RETCODE_REJECT:         return "REJECT";
         case TRADE_RETCODE_NO_MONEY:       return "NO_MONEY";
         case TRADE_RETCODE_TRADE_DISABLED: return "TRADE_DISABLED";
         case TRADE_RETCODE_MARKET_CLOSED:  return "MARKET_CLOSED";
         case TRADE_RETCODE_INVALID_STOPS:  return "INVALID_STOPS";
         case TRADE_RETCODE_INVALID_VOLUME: return "INVALID_VOLUME";
         case TRADE_RETCODE_INVALID_PRICE:  return "INVALID_PRICE";
         case TRADE_RETCODE_PRICE_OFF:      return "PRICE_OFF";
         case TRADE_RETCODE_PRICE_CHANGED:  return "PRICE_CHANGED";
         case TRADE_RETCODE_TIMEOUT:        return "TIMEOUT";
         case TRADE_RETCODE_CONNECTION:     return "CONNECTION";
         default:                           return StringFormat("RC=%d", code);
        }
     }
  };

#endif // FSQ_ERRORS_MQH
