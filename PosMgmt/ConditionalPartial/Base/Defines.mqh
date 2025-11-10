//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict

#ifndef MQLARTICLES_POSMGMT_CONDITIONALPARTIALS_DEFINES_MQH
#define MQLARTICLES_POSMGMT_CONDITIONALPARTIALS_DEFINES_MQH

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include  "..\\..\\..\\RM\\RiskManagement.mqh"

//+------------------------------------------------------------------+
//| Defines                                                          |
//+------------------------------------------------------------------+
#define CONDITIONAL_PARTIAL_ARR_MAIN_RESERVE 5
#define CONDITIONAL_PARTIAL_ARR_TO_REMOVE_RESERVE 2

//+------------------------------------------------------------------+
//| Interface for partial condition                                  |
//+------------------------------------------------------------------+
interface IConditionPartial
 {
public:
  void OnInitPartials(double initial_price);
  void OnNewDay();
  void OnNewWeek();
  void Execute(datetime current_time);
  string Name() const;
  bool CloseBuy();
  bool CloseSell();
 };

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
//--- Structure for partial configuration
struct ConditionalPartialConfig
 {
  //---
  IConditionPartial  *condition;
  CDiff              *min_distance_to_close_pos;
  string             str_percentage_volume_to_close;
  string             symbol;
  ulong              magic_number;
  bool               auto_mode;

  //---
                     ConditionalPartialConfig()
    :                str_percentage_volume_to_close(""), symbol(_Symbol), magic_number(NOT_MAGIC_NUMBER),
                     condition(NULL), min_distance_to_close_pos(NULL), auto_mode(true)
   {
   }

  //---
  bool               IsValid(string& error) const
   {
    if(!CheckPointer(condition))
     {
      error = "Invalid condition pointer";
      return false;
     }

    if(!CheckPointer(min_distance_to_close_pos))
     {
      error = "Invalid min distance pointer";
      return false;
     }
    return true;
   }

  //---
  bool               ConvertStrToDoubleArr(ushort separator, double& out[], string& error) const
   {
    //--- Convert
    if(!StrTo::CstArray(out, str_percentage_volume_to_close, separator))
     {
      error = StringFormat("When converting string %s\nTo double array", str_percentage_volume_to_close);
      return false;
     }

    //--- CheckSize
    const int size = ArraySize(out);
    if(size < 1)
     {
      error = StringFormat("Invalid %s string\nNo elements with separator = '%s'", str_percentage_volume_to_close, ShortToString(separator));
      return false;
     }
    return true;
   }
 };

//--- Structure to store a trackable position (to which partial closes will be applied until its removal)
struct ConditionalPartialTrackedPosition
 {
  ulong              ticket;
  double             next_min_price;
  ENUM_POSITION_TYPE type;
  int                next_index_to_close;
 };
//+------------------------------------------------------------------+
#endif 
