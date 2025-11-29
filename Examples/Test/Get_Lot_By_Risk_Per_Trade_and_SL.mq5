//+------------------------------------------------------------------+
//|                             Get Lot By Risk Per Trade and SL.mq5 |
//|                                                        Your name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Your name"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

#include "..\\..\\RM\\RiskManagement.mqh"

input ENUM_ORDER_TYPE InpOrderType  = ORDER_TYPE_BUY; // Order Type:
input double InpEntryPrice = 10.0 ;// Entry price
input double InpRiskPerOperation = 1.0; // Risk per operation in % of free margin
input long InpStopLossInPoints = 600; // Stop Loss in Points
input ulong InpDeviation = 0; // Deviation
input ulong InpStopLimit = 0; // StopLimit


//+------------------------------------------------------------------+
//| Main script function                                             |
//+------------------------------------------------------------------+
void OnStart()
 {
  CGetLote get_lote(_Symbol);

//--- Get Max Lot Size
  double max_lot_size = get_lote.GetMaxLote(InpOrderType, InpEntryPrice, InpDeviation, InpStopLimit);

//--- Get Lote
  double estimated_loss_in_account_money;
  const double ideal_lot_size = get_lote.GetLoteByRiskPerOperationAndSL(max_lot_size, InpRiskPerOperation, estimated_loss_in_account_money, InpStopLossInPoints);

  if(ideal_lot_size < get_lote.MinVolume())
   {
    //--- Invalid lot size
    Comment("The stop loss is too large or the risk per operation is low. Increase the risk or decrease the stop loss.");
   }
  else
   {
    //--- Display calculated values;
    Print("Maximum loss with SL: ", InpStopLossInPoints, " | Lot: ", ideal_lot_size, " is: ", estimated_loss_in_account_money);
    Comment("Ideal Lot: ", ideal_lot_size);
   }

  Sleep(10000); // Sleep for 10 seconds
  Comment(""); // Clean
 }
//+------------------------------------------------------------------+
