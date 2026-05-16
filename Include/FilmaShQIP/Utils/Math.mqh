//+------------------------------------------------------------------+
//|                                                          Math.mqh
//|              FilmaShQIP — XAUUSD Institutional EA
//|              Phase 1 — Core foundations
//+------------------------------------------------------------------+
//| Responsibility: Percentile, z-score, rolling mean/stddev, clamp
//| See docs/ARCHITECTURE.md §1.5.2
//+------------------------------------------------------------------+
#ifndef FSQ_MATH_MQH
#define FSQ_MATH_MQH

#property copyright "FilmaShQIP"
#property strict

class CFsqMath
  {
public:
   static double Clamp(double v, double lo, double hi)
     {
      if(v < lo) return lo;
      if(v > hi) return hi;
      return v;
     }

   static int ClampI(int v, int lo, int hi)
     {
      if(v < lo) return lo;
      if(v > hi) return hi;
      return v;
     }

   static double Mean(const double &arr[], int n)
     {
      if(n <= 0) return 0.0;
      double s = 0.0;
      for(int i = 0; i < n; i++) s += arr[i];
      return s / n;
     }

   static double StdDev(const double &arr[], int n)
     {
      if(n <= 1) return 0.0;
      double m = Mean(arr, n);
      double s = 0.0;
      for(int i = 0; i < n; i++)
        {
         double d = arr[i] - m;
         s += d * d;
        }
      return MathSqrt(s / (n - 1));
     }

   static double ZScore(double val, double mean, double sd)
     {
      return sd > 0.0 ? (val - mean) / sd : 0.0;
     }

   // Modifies arr (sorts). p in [0,100].
   static double Percentile(double &arr[], int n, double p)
     {
      if(n <= 0) return 0.0;
      ArraySort(arr);
      if(p < 0.0) p = 0.0;
      if(p > 100.0) p = 100.0;
      double rank = (p / 100.0) * (n - 1);
      int lo = (int)MathFloor(rank);
      int hi = (int)MathCeil(rank);
      if(lo == hi) return arr[lo];
      double frac = rank - lo;
      return arr[lo] + frac * (arr[hi] - arr[lo]);
     }

   static double Median(double &arr[], int n)
     {
      return Percentile(arr, n, 50.0);
     }
  };

#endif // FSQ_MATH_MQH
