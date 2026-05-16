//+------------------------------------------------------------------+
//|                                                       Defines.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Enums, magic, build flags, masked constants
//| See docs/ARCHITECTURE.md §1.1, §1.7
//+------------------------------------------------------------------+
#ifndef FSQ_DEFINES_MQH
#define FSQ_DEFINES_MQH

#property copyright "FilmaShQIP"
#property strict

#define FSQ_VERSION         "0.1.0"
#define FSQ_PRODUCT_NAME    "FilmaShQIP"
#define FSQ_FILES_SUBDIR    "FilmaShQIP"
#define FSQ_DEFAULT_MAGIC   270526001

#define K_GV_PEAK           "FSQ_PEAK"
#define K_GV_ANCHOR         "FSQ_ANCHOR"
#define K_GV_ANCHOR_DATE    "FSQ_ANCHORDT"
#define K_GV_KILL_ACTIVE    "FSQ_KILL"
#define K_GV_KILL_PERM      "FSQ_KILLPERM"
#define K_GV_LOSS_STREAK    "FSQ_STREAK"
#define K_GV_COOLDOWN_BAR   "FSQ_COOLDOWN"

#define K_FILE_STATE        "state.json"
#define K_FILE_LOG_PREFIX   "log_"
#define K_FILE_JOURNAL_PRX  "trades_"
#define K_FILE_CAL_CACHE    "calendar_cache.xml"

enum EPolicyMode
  {
   MODE_PROP         = 0,
   MODE_CONSERVATIVE = 1,
   MODE_AGGRESSIVE   = 2
  };

enum ESession
  {
   SESS_NONE    = 0,
   SESS_ASIA    = 1,
   SESS_LONDON  = 2,
   SESS_NY      = 3,
   SESS_OVERLAP = 4
  };

enum ENewsImpact
  {
   NEWS_LOW    = 1,
   NEWS_MEDIUM = 2,
   NEWS_HIGH   = 3
  };

enum ELogLevel
  {
   LOG_DEBUG = 0,
   LOG_INFO  = 1,
   LOG_WARN  = 2,
   LOG_ERROR = 3,
   LOG_FATAL = 4
  };

enum EAnchorKind
  {
   ANCHOR_EQUITY  = 0,
   ANCHOR_BALANCE = 1
  };

// Regime-relative constants (ATR multiples / counts). NEVER replace with pips/USD.
const double K_FVG_MIN_SIZE_ATR = 0.5;
const double K_DISPL_MIN_ATR    = 1.5;
const double K_SL_BUFFER_ATR    = 0.2;
const double K_VOL_SPIKE_K      = 3.0;
const double K_VOL_CASC_K       = 1.5;
const int    K_VOL_FREEZE_BARS  = 6;
const int    K_VOL_CASC_BARS    = 12;
const int    K_SWING_L_MIN      = 3;
const int    K_SWING_L_MAX      = 8;
const int    K_FVG_MAX_AGE      = 50;
const int    K_OB_MAX_AGE       = 100;
const int    K_SPREAD_HIST_LEN  = 300;
const int    K_ATR_PERIOD       = 14;
const int    K_SAFETY_PAD_PCT   = 10;

#endif // FSQ_DEFINES_MQH
