//+------------------------------------------------------------------+
//|                                                           Ea.mq5 |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Main.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBreakEvenPanel panel;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- Atr
  atr_ultra_optimized.SetVariables(_Period, _Symbol, 0, 14);
  atr_ultra_optimized.SetInternalPointer(); 
 
//---
  const int width = 500;
  const int height = 390;

//---
  panel.CreateGUI(width, height);

//---
  account_status.AddLogFlagTicket(InpLogLevelAccountStatus);
  account_status.AddLogFlags(InpLogLevelAccountStatus);
  account_status.OnInitEvent();

//---
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
//---
  panel.OnDeinitEvent(reason);
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
//---
  panel.OnTickEvent();
 }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
 {
//---
  account_status.OnTradeTransactionEvent(trans);
 }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
 {
//---
  panel.ChartEvent(id, lparam, dparam, sparam);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
 {
  panel.OnTimerEvent();
 }
//+------------------------------------------------------------------+
