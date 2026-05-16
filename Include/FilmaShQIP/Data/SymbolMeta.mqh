//+------------------------------------------------------------------+
//|                                                    SymbolMeta.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Auto-detect XAUUSD digits, tick-size, contract-size,
//|                 lot bounds; works across brokers (GOLD / XAUUSD /
//|                 XAUUSD.r / XAU/USD etc).
//| See docs/ARCHITECTURE.md §3.3, §R1
//+------------------------------------------------------------------+
#ifndef FSQ_SYMBOLMETA_MQH
#define FSQ_SYMBOLMETA_MQH

#property copyright "FilmaShQIP"
#property strict

class CFsqSymbolMeta
  {
private:
   string  m_symbol;
   int     m_digits;
   double  m_point;
   double  m_tick_size;
   double  m_tick_value;
   double  m_contract_size;
   double  m_min_lot;
   double  m_max_lot;
   double  m_lot_step;
   bool    m_detected;

public:
                     CFsqSymbolMeta()
     {
      m_symbol=""; m_digits=0; m_point=0; m_tick_size=0;
      m_tick_value=0; m_contract_size=0;
      m_min_lot=0; m_max_lot=0; m_lot_step=0; m_detected=false;
     }

   bool              Detect(string symbol = "")
     {
      m_symbol = (symbol == "") ? _Symbol : symbol;

      if(!SymbolSelect(m_symbol, true))
         return false;

      m_digits        = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      m_point         = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      m_tick_size     = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
      m_tick_value    = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
      m_contract_size = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      m_min_lot       = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      m_max_lot       = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      m_lot_step      = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);

      string up = m_symbol;
      StringToUpper(up);
      bool name_ok    = (StringFind(up, "XAU") >= 0 || StringFind(up, "GOLD") >= 0);
      bool digits_ok  = (m_digits == 2 || m_digits == 3);
      bool contract_ok = (m_contract_size >= 1.0 && m_contract_size <= 100.0);
      bool lot_ok     = (m_min_lot > 0.0 && m_lot_step > 0.0 && m_max_lot >= m_min_lot);

      m_detected = (name_ok && digits_ok && contract_ok && lot_ok);
      return m_detected;
     }

   bool              IsDetected()      { return m_detected; }
   string            Symbol()          { return m_symbol; }
   int               Digits()          { return m_digits; }
   double            Point()           { return m_point; }
   double            TickSize()        { return m_tick_size; }
   double            TickValuePerLot() { return m_tick_value; }
   double            ContractSize()    { return m_contract_size; }
   double            MinLot()          { return m_min_lot; }
   double            MaxLot()          { return m_max_lot; }
   double            LotStep()         { return m_lot_step; }

   double            PointValueUSD()
     {
      if(m_tick_size <= 0.0) return 0.0;
      return m_tick_value * (m_point / m_tick_size);
     }

   double            NormalizeLot(double lot)
     {
      if(lot < m_min_lot) return 0.0;
      double steps = MathFloor((lot - m_min_lot) / m_lot_step + 0.0000001);
      double norm  = m_min_lot + steps * m_lot_step;
      if(norm > m_max_lot) norm = m_max_lot;
      return NormalizeDouble(norm, 2);
     }

   string            Describe()
     {
      return StringFormat(
         "symbol=%s digits=%d point=%g tick_size=%g tick_val=%g contract=%g lot[%.2f..%.2f step %.2f]",
         m_symbol, m_digits, m_point, m_tick_size, m_tick_value, m_contract_size,
         m_min_lot, m_max_lot, m_lot_step);
     }
  };

#endif // FSQ_SYMBOLMETA_MQH
