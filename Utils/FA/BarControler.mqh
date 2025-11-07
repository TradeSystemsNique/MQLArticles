//+------------------------------------------------------------------+
//|                                                 BarControler.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict

#ifndef UTILS_FA_BAR_CONTROLER_MQH
#define UTILS_FA_BAR_CONTROLER_MQH

#include "FuncionesBases.mqh"

//+------------------------------------------------------------------+
//| Class to control the opening of a candle                         |
//+------------------------------------------------------------------+
class CBarControler
 {
private:
  const string       symbol;
  datetime           next_time;
  datetime           prev_time;
  const ENUM_TIMEFRAMES    bar_timeframe;
  const int          period_in_seconds;

public:
                     CBarControler(ENUM_TIMEFRAMES _timeframe, string _symbol);
  inline int         PeriodsInSeconds()const { return  period_in_seconds; }
  inline             ENUM_TIMEFRAMES Timeframe() const { return bar_timeframe; }
  bool               IsNewBar(datetime curr_time);
  inline datetime    GetNextPrevBarTime() const { return prev_time; }
 };
//+------------------------------------------------------------------+
CBarControler::CBarControler(ENUM_TIMEFRAMES _timeframe, string _symbol)
  : next_time(wrong_datetime), prev_time(wrong_datetime), period_in_seconds(PeriodSeconds(_timeframe)), symbol(_symbol), bar_timeframe(_timeframe)
 {
 }
//+------------------------------------------------------------------+
bool CBarControler::IsNewBar(datetime curr_time)
 {
  if(curr_time >= next_time)
   {
    prev_time = next_time;
    next_time =  iTime(symbol, bar_timeframe, 0) + (bar_timeframe == PERIOD_MN1 ? SecondsInMonth(curr_time) : period_in_seconds);
    return true;
   }
  return false;
 }


//+------------------------------------------------------------------+
//| Class to control the opening of a candle  ("fast")               |
//+------------------------------------------------------------------+
class CBarControlerFast
 {
private:
  const string       symbol;
  datetime           next_time;
  const ENUM_TIMEFRAMES    bar_timeframe;
  const int          period_in_seconds;
  const bool         is_mn1;

public:
                     CBarControlerFast(ENUM_TIMEFRAMES _timeframe, string _symbol);
  inline ENUM_TIMEFRAMES Timeframe() const { return bar_timeframe; }
  bool               IsNewBar(datetime curr_time);
 };
//+------------------------------------------------------------------+
CBarControlerFast::CBarControlerFast(ENUM_TIMEFRAMES _timeframe, string _symbol)
  : next_time(wrong_datetime), period_in_seconds(PeriodSeconds(_timeframe)), bar_timeframe(_timeframe), symbol(_symbol), is_mn1((_timeframe == PERIOD_MN1))
 {
 }
//+------------------------------------------------------------------+
bool CBarControlerFast::IsNewBar(datetime curr_time)
 {
  if(curr_time >= next_time)
   {
    next_time =  iTime(symbol, bar_timeframe, 0) + (!is_mn1 ? period_in_seconds : SecondsInMonth(curr_time));
    return true;
   }
  return false;
 }

#endif
//+------------------------------------------------------------------+
