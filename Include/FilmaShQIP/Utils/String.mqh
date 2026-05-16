//+------------------------------------------------------------------+
//|                                                        String.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Format helpers (lot, price, R-multiple, JSON-escape)
//+------------------------------------------------------------------+
#ifndef FSQ_STRING_MQH
#define FSQ_STRING_MQH

#property copyright "FilmaShQIP"
#property strict

class CFsqString
  {
public:
   static string FormatLot(double lot)
     {
      return DoubleToString(lot, 2);
     }

   static string FormatPrice(double p, int digits)
     {
      return DoubleToString(p, digits);
     }

   static string FormatR(double r)
     {
      return StringFormat("%.2fR", r);
     }

   static string FormatPct(double p)
     {
      return StringFormat("%.2f%%", p * 100.0);
     }

   static string FormatUSD(double v)
     {
      return StringFormat("$%.2f", v);
     }

   static string JsonEscape(string s)
     {
      string r = "";
      int n = StringLen(s);
      for(int i = 0; i < n; i++)
        {
         ushort c = StringGetCharacter(s, i);
         if(c == '"')       r += "\\\"";
         else if(c == '\\') r += "\\\\";
         else if(c == '\n') r += "\\n";
         else if(c == '\r') r += "\\r";
         else if(c == '\t') r += "\\t";
         else if(c < 32)    r += StringFormat("\\u%04x", c);
         else               r += ShortToString(c);
        }
      return r;
     }
  };

#endif // FSQ_STRING_MQH
