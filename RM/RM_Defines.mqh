//+------------------------------------------------------------------+
//|                                                   RM_Defines.mqh |
//|                                     Niquel y Leo, Copyright 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Niquel y Leo, Copyright 2025"
#property link      "https://www.mql5.com"
#property strict

#ifndef MQLARTICLES_RM_RDEFINES_MQH
#define MQLARTICLES_RM_RDEFINES_MQH

//+------------------------------------------------------------------+
//|                        Defines                                   |
//+------------------------------------------------------------------+
#define NOT_MAGIC_NUMBER 2//Not Magic Number 
#define FLAG_CLOSE_ALL_PROFIT 2 //Flag indicating to close only operations with profit
#define FLAG_CLOSE_ALL_LOSS   4 //Flag indicating to close only operations without profit

//--- positions
#define  FLAG_POSITION_TYPE_BUY 8
#define  FLAG_POSITION_TYPE_SELL 16

//--- orders
#define FLAG_ORDER_TYPE_BUY             1
#define FLAG_ORDER_TYPE_SELL            2
#define FLAG_ORDER_TYPE_BUY_LIMIT       4
#define FLAG_ORDER_TYPE_SELL_LIMIT      8
#define FLAG_ORDER_TYPE_BUY_STOP        16
#define FLAG_ORDER_TYPE_SELL_STOP       32
#define FLAG_ORDER_TYPE_BUY_STOP_LIMIT  64
#define FLAG_ORDER_TYPE_SELL_STOP_LIMIT 128
#define FLAG_ORDER_TYPE_CLOSE_BY        256

//---
#define RISK_MANGEMENT_LOSS_PROFIT_MIN_VALUE 1e-4

//--- Losses Profits
#define LOSS_PROFIT_COUNT 8

//--- Tickets
#define INVALID_TICKET 0
//+------------------------------------------------------------------+
//|                      Enumerations                                |
//+------------------------------------------------------------------+
enum ENUM_LOTE_TYPE //lot type
 {
  Dinamico,//Dynamic
  Fijo//Fixed
 };

//--- Enumeration to define the types of calculation of the value of maximum profits and losses
enum ENUM_RISK_CALCULATION_MODE
 {
  money = 0, //Money
  percentage //Percentage %
 };

const string RiskCalcModeToString[2]
 {
  "Money",
  "Percentage"
 };

//--- Enumeration to define the type of risk management
enum ENUM_MODE_RISK_MANAGEMENT
 {
  risk_mode_propfirm_dynamic_daiy_loss, //Prop Firm (FTMO-FundendNext)
  risk_mode_personal_account // Personal Account
 };

//--- Enumeration to define the value to which the percentages will be applied
enum ENUM_APPLIED_PERCENTAGES
 {
  Balance = 0, //Balance
  ganancianeta = 1,//Net profit
  free_margin = 2, //Free margin
  equity = 3 //Equity
 };

//--- Enumeration for ways to obtain the lot
enum ENUM_GET_LOT
 {
  GET_LOT_BY_ONLY_RISK_PER_OPERATION, //Obtain the lot for the risk per operation
  GET_LOT_BY_STOPLOSS_AND_RISK_PER_OPERATION //Obtain and adjust the lot through the risk per operation and stop loss respectively.
 };

//--- Mode to check if a maximum loss or gain has been exceeded
enum MODE_SUPERATE
 {
  EQUITY = 0, //Only Equity
  CLOSE_POSITION = 1, //Only for closed positions
  CLOSE_POSITION_AND_EQUITY = 2//Closed positions and equity
 };

//--- Enumeration of the types of dynamic operational risk
enum ENUM_OF_DYNAMIC_MODES_OF_GMLPO
 {
  DYNAMIC_GMLPO_FULL_CUSTOM, //Customisable dynamic risk per operation
  DYNAMIC_GMLPO_FIXED_PARAMETERS,//Risk per operation with fixed parameters
  NO_DYNAMIC_GMLPO //No dynamic risk for risk per operation
 };

enum ENUM_LOSS_PROFIT
 {
  T_LOSS,
  T_PROFIT,
  T_GMLPO
 };

enum ENUM_TYPE_LOSS_PROFIT
 {
  LP_MDP = 0, //Maxima ganancias diaria
  LP_MWP = 1,//Maxima ganancia semanal
  LP_MMP = 2,//Maxima ganancia mensual

  LP_MDL = 3, //Maxima perdida diaria
  LP_MWL = 4, //Maxima perdida semanal
  LP_MML = 5, //Maxima perdida mensual
  LP_ML = 6, //Maxima perdida total
  LP_GMLPO = 7 //Maxima perdida por operacion
 };


//+------------------------------------------------------------------+
//|                      Structures                                  |
//+------------------------------------------------------------------+
//--- Positions
struct pack(sizeof(double)) Position //remove pack if it increases to +4bytes
 {
  ulong              ticket; //position ticket
  ulong              magic; //magic number with which it was opened
  double             profit; //last recorded profit
  double             open_price; //opening price
  double             firt_sl; //stop loss with which the position was opened, original sl (I put first because the StopLoss can be modified either by the user or by a bot)
  double             first_tp; //first tp, original
  datetime           open_time; //opening time
  ENUM_POSITION_TYPE type; //position type
 };
 
//--- Order
struct pack(8) ROnOrderDelete
 {
  ulong              order_magic; //magic number of the order
  ulong              order_ticket; //order ticket
  ENUM_ORDER_TYPE    order_type; //order type
  ENUM_ORDER_STATE   order_state; //order state
 };
 
//---
struct ModifierOnOpenCloseStruct
 {
  //--- Last deal info
  ulong              deal_ticket;     // Deal ticket
  double             deal_profit;     // Deal profit
  ENUM_DEAL_REASON   deal_reason;     // Deal reason
  ENUM_DEAL_ENTRY    deal_entry_type; // Deal entry type
  
  //--- Magic number profit
  double             profit_diario;  // Daily profit regarding the magic number of (RiskManagement)
  double             profit_semanal; // Weekly profit regarding the magic number of (RiskManagement)
  double             profit_total;   // Total profit regarding the magic number of (RiskManagement)
  double             profit_mensual; // Monthly profit regarding the magic number of (RiskManagement)
 
  //--- Open position info or closed position info
  Position           position;
 };
 
//---
struct ROnOpenClosePosition
 {
  //--- Position
  Position           position;
  
  //--- Deal
  ulong              deal_ticket; // Ticket
  double             deal_profit; // Profit
  ENUM_DEAL_REASON   deal_reason; // Reason
  ENUM_DEAL_ENTRY    deal_entry_type; // Entry type
  
  //--- Account
  double             account_balance;        // Account balance
  double             account_profit_diario;  // Account daily profit
  double             account_profit_semanal; // Account weekly profit
  double             account_profit_total;   // Account total profit
  double             account_profit_mensual; // Account monthly profit
  
  //--- Extra
  ulong              magic_number_closed; // Magic number at position close
 };
 
//--- Loss/Profit
struct Loss_Profit
 {
  double             value; //value
  double             assigned_percentage; //percentage to apply
  ENUM_RISK_CALCULATION_MODE mode_calculation_risk; //risk calculation method
  ENUM_APPLIED_PERCENTAGES percentage_applied_to; //percentage applied to
 };
 
//--- Dynamic gmlpo/ Dynamic risk per operation
struct Dynamic_LossProfit
 {
  double             balance_to_activate_the_risk[];
  double             risk_to_be_adjusted[];
 };
 
//---
struct RiskParams
 {
  ENUM_MODE_RISK_MANAGEMENT mode;
  MqlParam           params[];
 };
 
//---
struct ModfierInitInfo
 {
  double             balance;
  ulong              magic;
 };

//+------------------------------------------------------------------+
//| Arrays para las ordenes                                          |
//+------------------------------------------------------------------+
const bool EsUnaOrderPendiente[9]
 {
  false, // 0
  false, // 1
  true, // 2
  true, // 3
  true, // 4
  true, // 4
  true, // 5
  true, // 7
  false // 8
 };

const int OrdensToFlagArray[9] =
 {
  FLAG_ORDER_TYPE_BUY,              // 0
  FLAG_ORDER_TYPE_SELL,             // 1
  FLAG_ORDER_TYPE_BUY_LIMIT,        // 2
  FLAG_ORDER_TYPE_SELL_LIMIT,       // 3
  FLAG_ORDER_TYPE_BUY_STOP,         // 4
  FLAG_ORDER_TYPE_SELL_STOP,        // 5
  FLAG_ORDER_TYPE_BUY_STOP_LIMIT,   // 6
  FLAG_ORDER_TYPE_SELL_STOP_LIMIT,  // 7
  FLAG_ORDER_TYPE_CLOSE_BY          // 8
 };

/*
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_BUY = 0
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_SELL = 1
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_BUY_LIMIT = 2
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_SELL_LIMIT = 3
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_BUY_STOP = 4
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_SELL_STOP = 5
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_BUY_STOP_LIMIT = 6
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_SELL_STOP_LIMIT = 7
2025.08.06 16:50:41.989 GetID (XAUUSD,M1) ORDER_TYPE_CLOSE_BY = 8
*/
//+------------------------------------------------------------------+
#endif // MQLARTICLES_RM_RDEFINES_MQH
//+------------------------------------------------------------------+
