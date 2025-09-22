//+------------------------------------------------------------------+
//|                                                   RM_Defines.mqh |
//|                                     Niquel y Leo, Copyright 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Niquel y Leo, Copyright 2025"
#property link      "https://www.mql5.com"
#property strict

#ifndef RISK_RM_DEFINES_MQH
#define RISK_RM_DEFINES_MQH

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
  money, //Money
  percentage //Percentage %
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
struct pack(sizeof(double)) Position //quitar pack si aumenta a+4bytes
 {
  ulong              ticket; //position ticket
  ulong              magic; //numero magico con el que se abrio
  double             profit; //ultimo profit registrado
  double             open_price; //precio de apertura
  double             firt_sl; //stop loss con el que se abrio la operacion, sl original (pongo first por que se puede modificar el StopLoss ya sea por el usuario o por un bot)
  double             first_tp; //primer tp, original
  datetime           open_time; //tiempo de apertura
  ENUM_POSITION_TYPE type; //position type
 };



//--- Orden
struct pack(8) ROnOrderDelete
 {
  ulong              order_magic; //numjero mafgico de la orden
  ulong              order_ticket; //ticket de la orden
  ENUM_ORDER_TYPE    order_type; //tipo de orden
  ENUM_ORDER_STATE   order_state; //stado de la orden
 };


//---
struct ModifierOnOpenCloseStruct
 {
  //--- Info del ultimo deal
  ulong              deal_ticket;
  double             deal_profit;
  ENUM_DEAL_REASON   deal_reason;
  ENUM_DEAL_ENTRY    deal_entry_type;

  //--- Profit del numnero magico
  double             profit_diario;
  double             profit_semanal;
  double             profit_total;
  double             profit_mensual;


  //--- Info de la posicion abierta o de la posicion que se cerro
  Position           position;
 };


//---
struct ROnOpenClosePosition
 {
  ulong              deal_ticket;
  double             deal_profit;
  ENUM_DEAL_REASON   deal_reason;
  ENUM_DEAL_ENTRY    deal_entry_type;

  //--- Cuenta
  double             account_balance;
  double             account_profit_diario;
  double             account_profit_semanal;
  double             account_profit_total;
  double             account_profit_mensual;

  //--- Posicion
  Position           position;

  //--- Extra
  ulong              magic_number_closed;
 };


//--- Loss/Profit
struct Loss_Profit
 {
  double             value; //value
  double             assigned_percentage; //percentage to apply
  ENUM_RISK_CALCULATION_MODE mode_calculation_risk; //risk calculation method
  ENUM_APPLIED_PERCENTAGES percentage_applied_to; //percentage applied to
 };

//--- Dynamic gmlpo/ Riesgo por operacion dinamico
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
#endif 