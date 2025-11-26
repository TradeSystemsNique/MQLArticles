//+------------------------------------------------------------------+
//|                                           Order Block EA MT5.mq5 |
//|                                                        Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property tester_indicator "OrderBlockIndPart2.ex5"
#resource "\\Shared Projects\\MQLArticles\\Ob\\Indicator\\OrderBlockIndPart2.ex5"

enum ENUM_TP_SL_STYLE
 {
  ATR = 0, //Atr
  POINT = 1 //Fixed Points
 };


#include  "..\\..\\..\\PosMgmt\\Breakeven.mqh"
#include  "..\\..\\..\\PosMgmt\\Partials.mqh"
CTrade tradep;

sinput group "-------| Order Block EA settings |-------"
input ulong InpMagic = 545244; //Magic number
input ENUM_TIMEFRAMES InpTimeframeOrderBlock = PERIOD_M5; //Order block timeframe

sinput group "-- Order Block --"
input int  InpRangoUniversalBusqueda = 500; //search range of order blocks
input int  InpWidthOrderBlock = 1; //Width order block
input bool InpBackOrderBlock = true; //Back order block?
input bool InpFillOrderBlock = true; //Fill order block?
input color InpColorOrderBlockBajista = clrRed; //Bearish order block color
input color InpColorOrderBlockAlcista = clrGreen; //Bullish order block color

input double InpTransparency = 0.5; // Transparency from 0.0 (invisible) to 1.0 (opaque)

sinput group ""
sinput group "-------| Strategy |-------"
input ENUM_TP_SL_STYLE InpTpSlStyle = ATR;//Tp and sl style:

sinput group "- TP SL by ATR "
input double InpAtrMultiplier1 = 9.3;//Atr multiplier 1 (SL)
input double InpAtrMultiplier2 = 24.4;//Atr multiplier 2 (TP)

sinput group "- TP SL by POINT "
input int InpTpPoint = 1000; //TP in Points
input int InpSlPoint = 1000; //SL in Points


sinput group ""
sinput group "-------| Account Status |-------"
input ENUM_VERBOSE_LOG_LEVEL InpLogLevelAccountStatus = VERBOSE_LOG_LEVEL_ERROR_ONLY; //(Account Status|Ticket Mangement) log level:

sinput group ""
sinput group "-------| Risk Management |-------"
input ENUM_LOTE_TYPE InpLoteType = Dinamico; //Lote Type:
input double InpLote = 0.1; //Lot size (only for fixed lot)
input ENUM_MODE_RISK_MANAGEMENT InpRiskMode = risk_mode_personal_account; //type of risk management mode
input ENUM_GET_LOT InpGetMode = GET_LOT_BY_STOPLOSS_AND_RISK_PER_OPERATION; //How to get the lot
input double InpPropFirmBalance = 0; //If risk mode is Prop Firm FTMO, then put your ftmo account balance
input ENUM_VERBOSE_LOG_LEVEL InpLogLevelRiskManagement = VERBOSE_LOG_LEVEL_ERROR_ONLY; //Risk Management log level:

sinput group "- ML/Maximum loss/Maximum loss -"
input double InpPercentageOrMoneyMlInput = 0; //percentage or money (0 => not used ML)
input ENUM_RISK_CALCULATION_MODE InpModeCalculationMl = percentage; //Mode calculation Max Loss
input ENUM_APPLIED_PERCENTAGES InpAppliedPercentagesMl = Balance; //ML percentage applies to:

sinput group "- MWL/Maximum weekly loss/Maximum weekly loss -"
input double InpPercentageOrMoneyMwlInput  = 0; //percentage or money (0 => not used MWL)
input ENUM_RISK_CALCULATION_MODE InpModeCalculationMwl = percentage; //Mode calculation Max weekly Loss
input ENUM_APPLIED_PERCENTAGES InpAppliedPercentagesMwl = Balance;//MWL percentage applies to:

sinput group "- MDL/Maximum  daily loss/Maximum daily loss -"
input double InpPercentageOrMoneyMdlInput  = 3.0; //percentage or money (0 => not used MDL)
input ENUM_RISK_CALCULATION_MODE InpModeCalculationMdl = percentage; //Mode calculation Max daily loss
input ENUM_APPLIED_PERCENTAGES InpAppliedPercentagesMdl = Balance;//MDL percentage applies to:

sinput group "- GMLPO/Gross maximum loss per operation/Percentage to risk per operation -"
input ENUM_OF_DYNAMIC_MODES_OF_GMLPO InpModeGmlpo = NO_DYNAMIC_GMLPO; //Select GMLPO mode:
input double InpPercentageOrMoneyGmlpoInput  = 2.0; //percentage or money (0 => not used GMLPO)
input ENUM_RISK_CALCULATION_MODE InpModeCalculationGmlpo = percentage; //Mode calculation Max Loss per operation
input ENUM_APPLIED_PERCENTAGES InpAppliedPercentagesGmlpo = Balance;//GMPLO percentage applies to:

sinput group "-- Optional GMLPO settings, Dynamic GMLPO"
sinput group "--- Full customizable dynamic GMLPO"
input string InpNote1 = "subtracted from your total balance to establish a threshold.";  //This parameter determines a specific percentage that will be
input string InpStrPercentagesToBeReviewed = "15,30,50"; //percentages separated by commas.
input string InpNote2 = "a new risk level will be triggered on your future trades: "; //When the current balance (equity) falls below this threshold
input string InpStrPercentagesToApply = "10,20,25"; //percentages separated by commas.
input string InpNote3 = "0 in both parameters => do not use dynamic risk in gmlpo"; //Note:

sinput group "--- Fixed dynamic GMLPO with parameters"
sinput group "- 1 -"
input string InpNote11 = "subtracted from your total balance to establish a threshold.";  //This parameter determines a specific percentage that will be
input double InpBalancePercentageToActivateTheRisk1 = 2.0; //percentage 1 that will be exceeded to modify the risk separated by commas
input string InpNote21 = "a new risk level will be triggered on your future trades: "; //When the current balance (equity) falls below this threshold
input double InpPercentageToBeModified1 = 1.0;//new percentage 1 to which the gmlpo is modified
sinput group "- 2 -"
input double InpBalancePercentageToActivateTheRisk2 = 5.0;//percentage 2 that will be exceeded to modify the risk separated by commas
input double InpPercentageToBeModified2 = 0.7;//new percentage 2 to which the gmlpo is modified
sinput group "- 3 -"
input double InpBalancePercentageToActivateTheRisk3 = 7.0;//percentage 3 that will be exceeded to modify the risk separated by commas
input double InpPercentageToBeModified3 = 0.5;//new percentage 3 to which the gmlpo is modified
sinput group "- 4 -"
input double InpBalancePercentageToActivateTheRisk4 = 9.0;//percentage 4 that will be exceeded to modify the risk separated by commas
input double InpPercentageToBeModified4 = 0.33;//new percentage 4  1 to which the gmlpo is modified

sinput group "-- MDP/Maximum daily profit/Maximum daily profit --"
input bool InpMdpIsStrict = true; //MDP is strict?
input double InpPercentageOrMoneyMdpInput = 11.0; //percentage or money (0 => not used MDP)
input ENUM_RISK_CALCULATION_MODE InpModeCalculationMdp = percentage; //Mode calculation Max Daily Profit
input ENUM_APPLIED_PERCENTAGES InpAppliedPercentagesMdp = Balance;//MDP percentage applies to:

sinput group ""
sinput group "-------| Risk Modifier |-------"
input bool InpActivarModificadorDeRiesgo = false; // Enables dynamic risk adjustment (Booster)
input double InpStepMod = 2.0;                 // Increment applied to risk each time the condition is met
input double InpStart = 2.0;                    // Profit percentage from which risk adjustment begins
input ENUM_MULTIPLIER_METHOD_DR InpMethodDr = DR_EXPONECIAL; // Type of progression used to increase risk

sinput group ""
sinput group "-------| Risk modifier 2 |-------"
input bool InpActivarModificadorDeRiesgo2 = false; //Activate risk modifier 2
input string InpStrPercentagesToApplyRiesgoCts = "6, 8, 10, 20, 25"; //Percentages to apply

sinput group ""
sinput group "-------| Risk modifier 3 by Kevin |-------"
input bool InpActivarModificadorDeRiesgo3 = false; //Activate risk modifier 3
input double InpConstante = 8.0; //Function constant

sinput group ""
sinput group "-------| Session |-------"
input char InpPaSessionStartHour = 1;   // Start hour to operate (0-23)
input char InpPaSessionStartMinute = 0; // Start minute to operate (0-59)
input char InpPaSessionEndHour = 23;    // End hour to operate (1-23)
input char InpPaSessionEndMinute = 0;  // End minute to operate (0-59)

sinput group ""
sinput group "-------| Breakeven |-------"
input         bool InpUseBe                       = true;               // Enable Breakeven logic
input ENUM_BREAKEVEN_TYPE InpTypeBreakEven       = BREAKEVEN_TYPE_RR;  // Calculation method (RR, ATR, or fixed points)
input ENUM_VERBOSE_LOG_LEVEL InpLogLevelBe      = VERBOSE_LOG_LEVEL_ERROR_ONLY; // Break Even log level:

sinput group "--- Breakeven based on Risk/Reward (RR) ---"
input         string InpBeRrAdv                  = "Requires a configured Stop Loss.";  // Warning: Stop Loss is required to calculate RR
input         double InpBeRrDbl                  = 1.0;                                 // Risk/Reward ratio to activate Breakeven (e.g. 1.0)
input ENUM_TYPE_EXTRA_BE_BY_RRR InpBeTypeExtraRr = EXTRA_BE_RRR_BY_ATR;                // Method to adjust Breakeven price (ATR or points)
input         double InpBeExtraPointsRrOrAtrMultiplier = 1.0;                       // Adjustment value: ATR multiplier (atr 14 period) if method = ATR, or fixed points if method = Points

sinput group "--- Breakeven based solely on ATR ---"
input         double InpBeAtrMultiplier          = 2.0;    // ATR multiplier to trigger Breakeven (atr 14 period)
input         double InpBeAtrMultiplierExtra    = 1.0;    // Additional multiplier for precise Breakeven adjustment (atr 14 period)

sinput group "--- Breakeven based on fixed points ---"
input         int InpBeFixedPointsToPutBe     = 200;   // Minimum distance (in points) to trigger Breakeven
input         int InpBeFixedPointsExtra         = 100;   // Extra points added when Breakeven is triggered

sinput group ""
sinput group "-------| Partial Closures |-------"
input ENUM_VERBOSE_LOG_LEVEL InpLogLevelPartials  = VERBOSE_LOG_LEVEL_ALL; // Partial Closures log level
input string InpComentVolumen4 = "Use '0' in both to disable. Order from lowest to highest."; //->
input string InpPartesDelTpDondeSeTomaraParciales = "0";    // Percentage of TP distance where partials trigger
input string InpComentParciales1 = "List of TP levels (%) to trigger partials."; //->
input string InpComentParciales2 = "Ex: \"25,50,75\" triggers at 25%, 50%, 75%."; //->
input string InpComentParciales3 = "String allows multiple dynamic levels."; //->
input string InpSeparatorPar = ""; // -------
input string InpVolumenQueSeQuitaraDeLaPosicionEnPorcentaje = "0";  // Volume to close at each defined level
input string InpComentVolumen1 = "Percentage of total volume closed at each level."; //->
input string InpComentVolumen2 = "Must match count of TP level entries."; //->
input string InpComentVolumen3 = "Ex: \"30,40,30\" closes 30%, 40%, then 30%."; //->


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CRiskManagemet *risk;
CBreakEven break_even(InpMagic, _Symbol);
CPartials g_partials;

//--- Handles
int order_block_indicator_handle;
int hanlde_ma;

//--- Global buffers
double tp1[];
double tp2[];
double sl1[];
double sl2[];

//--- Session
datetime start_sesion;
datetime end_sesion;

//--- General
CBarControlerFast bar_d1(PERIOD_D1, _Symbol);
CBarControlerFast bar_w1(PERIOD_W1, _Symbol);
CBarControlerFast bar_mn1(PERIOD_MN1, _Symbol);
CBarControlerFast bar_curr(PERIOD_CURRENT, _Symbol);
CDynamicRisk riesgo_c(InpStepMod, InpStart, LP_GMLPO, InpMethodDr);
CModifierDynamicRisk risk_modificator(InpStrPercentagesToApplyRiesgoCts);
CMathDynamicRisk risk_modificator_kevin(InpConstante);

//---
bool opera = true;
CAtrUltraOptimized atr_ultra_optimized;
const CLossProfitManager* g_loss_profit_manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- Atr
  atr_ultra_optimized.SetVariables(_Period, _Symbol, 0, 14);
  atr_ultra_optimized.SetInternalPointer();

//--- We set the breakeven values so its use is allowed
  if(InpUseBe)
   {
    break_even.SetBeByAtr(InpBeAtrMultiplier, InpBeAtrMultiplierExtra, GetPointer(atr_ultra_optimized));
    break_even.SetBeByFixedPoints(InpBeFixedPointsToPutBe, InpBeFixedPointsExtra);
    break_even.SetBeByRR(InpBeRrDbl, InpBeTypeExtraRr, InpBeExtraPointsRrOrAtrMultiplier, GetPointer(atr_ultra_optimized));
    break_even.SetInternalPointer(InpTypeBreakEven);
    break_even.obj.AddLogFlags(InpLogLevelBe);
   }

//--- Partials
  g_partials.AddLogFlags(InpLogLevelPartials);
  if(g_partials.Init(InpMagic, _Symbol, InpVolumenQueSeQuitaraDeLaPosicionEnPorcentaje, InpPartesDelTpDondeSeTomaraParciales))
   {
    account_status.AddItemFast(&g_partials);
   }


//--- Indicators
// Create ob handle
  order_block_indicator_handle = CreateIndicatorObHandle();

// Create ma handle
  hanlde_ma = iMA(_Symbol, InpTimeframeOrderBlock, 30, 0, MODE_EMA, PRICE_CLOSE);

// Check ma
  if(hanlde_ma == INVALID_HANDLE)
   {
    Print("The ema indicator is not available latest error: ", _LastError);
    return INIT_FAILED;
   }

  ChartIndicatorAdd(0, 0, hanlde_ma);

//--- Trade
  tradep.SetExpertMagicNumber(InpMagic);

//--- Risk management
  CRiskPointer* manager = new CRiskPointer(InpMagic, InpGetMode);
  manager.SetPropirm(InpPropFirmBalance);
  risk = manager.GetRiskPointer(InpRiskMode);
  risk.AddLogFlags(InpLogLevelRiskManagement);
  risk.SetLote(CreateLotePtr(_Symbol));


// We set the parameters
  string to_apply = InpStrPercentagesToApply, to_modfied = InpStrPercentagesToBeReviewed;

  if(InpModeGmlpo == DYNAMIC_GMLPO_FIXED_PARAMETERS)
    SetDynamicUsingFixedParameters(InpBalancePercentageToActivateTheRisk1, InpBalancePercentageToActivateTheRisk2, InpBalancePercentageToActivateTheRisk3
                                   , InpBalancePercentageToActivateTheRisk4, InpPercentageToBeModified1, InpPercentageToBeModified2, InpPercentageToBeModified3, InpPercentageToBeModified4
                                   , to_modfied, to_apply);

  risk.AddLoss(InpPercentageOrMoneyMdlInput, InpAppliedPercentagesMdl, InpModeCalculationMdl, LP_MDL, true);
  risk.AddLoss(InpPercentageOrMoneyGmlpoInput, InpAppliedPercentagesGmlpo, InpModeCalculationGmlpo, LP_GMLPO, true, (InpModeGmlpo != NO_DYNAMIC_GMLPO), to_modfied, to_apply);
  risk.AddLoss(InpPercentageOrMoneyMlInput, InpAppliedPercentagesMl, InpModeCalculationMl, LP_ML, true);
  risk.AddLoss(InpPercentageOrMoneyMwlInput, InpAppliedPercentagesMwl, InpModeCalculationMwl, LP_MWL, true);
  risk.AddProfit(InpPercentageOrMoneyMdpInput, InpAppliedPercentagesMdp, InpModeCalculationMdp, LP_MDP, InpMdpIsStrict);
  risk.EndAddProfitLoss(); // Execute this every time we finish setting the maximum losses and profits
  g_loss_profit_manager = risk.GetLossProfitManager();
  

// We add modifiers
  if(InpActivarModificadorDeRiesgo)
    risk.AddModificator(riesgo_c);

  if(InpActivarModificadorDeRiesgo2)

    risk.AddModificator(risk_modificator);

  if(InpActivarModificadorDeRiesgo3)
    risk.AddModificator(risk_modificator_kevin);

// We finish by adding it
  account_status.AddItemFast(risk);

// We delete the temporary pointer
  delete manager;

//--- We initialize the account
  account_status.AddLogFlagTicket(InpLogLevelAccountStatus);
  account_status.AddLogFlags(InpLogLevelAccountStatus);
  account_status.OnInitEvent();

//--- We configure the arrays in series
  ArraySetAsSeries(tp1, true);
  ArraySetAsSeries(tp2, true);
  ArraySetAsSeries(sl1, true);
  ArraySetAsSeries(sl2, true);
  return(INIT_SUCCEEDED);
 }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
//---
  ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, GetMovingAverageIndex()));
  ChartIndicatorDelete(0, 0, "Order Block Indicator");

  if(hanlde_ma != INVALID_HANDLE)
    IndicatorRelease(hanlde_ma);

  if(order_block_indicator_handle != INVALID_HANDLE)
    IndicatorRelease(order_block_indicator_handle);
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
//--- General
  const datetime time_curr = TimeCurrent();

//--- Code that runs every new day
  if(bar_d1.IsNewBar(time_curr))
   {
    //---
    account_status.OnNewDay();
    opera = true;

    //---
    if(bar_w1.IsNewBar(time_curr))
     {
      account_status.OnNewWeek();

      if(bar_mn1.IsNewBar(time_curr))
        account_status.OnNewMonth();
     }
   }

//---
  if(account_status_positions_open)
   {
    CAccountStatus_OnTickEvent
    if(opera)
     {
      if(g_loss_profit_manager.MaxLossIsSuperated())
       {
        const ENUM_TYPE_LOSS_PROFIT type = g_loss_profit_manager.GetLastLossSuperatedType();
        if(type == LP_ML)
         {
          if(InpRiskMode == risk_mode_propfirm_dynamic_daiy_loss)
           {
            Print("The expert advisor lost the funding test");
           }
          else
           {
            Print("Maximum loss exceeded now");
           }

          //---
          Remover();
         }
        else
          if(type == LP_MDL)
           {
            Print("Maximum daily loss exceeded now");
           }

        //---
        risk.CloseAllPositions();
        opera = false;
       }
      else
        if(g_loss_profit_manager.MaxProfitIsSuperated())
         {
          if(g_loss_profit_manager.GetLastProfitSuperatedType() != LP_MDP)
            return;
          risk.CloseAllPositions();
          Print("Excellent Maximum daily profit achieved");
          opera = false;
         }
     }
   }

//--- Check Session
  if(time_curr > end_sesion)
   {
    start_sesion = HoraYMinutoADatetime(InpPaSessionStartHour, InpPaSessionStartMinute, time_curr);
    end_sesion = HoraYMinutoADatetime(InpPaSessionEndHour, InpPaSessionEndMinute, time_curr);

    if(start_sesion > end_sesion)
      end_sesion = end_sesion + 86400;
   }

//--- Breakeven
  if(InpUseBe)
    break_even.obj.BreakEven();

//--- Partials
  g_partials.CheckTrackedPositions();

//--- Check to operate
  if(!opera)
    return;

//--- Strategy
  if(bar_curr.IsNewBar(time_curr))
   {
    if(time_curr > start_sesion && time_curr < end_sesion)
     {
      if(risk.GetPositionsTotal() == 0)
       {
        CopyBuffer(order_block_indicator_handle, 2, 0, 5, tp1);
        CopyBuffer(order_block_indicator_handle, 3, 0, 5, tp2);
        CopyBuffer(order_block_indicator_handle, 4, 0, 5, sl1);
        CopyBuffer(order_block_indicator_handle, 5, 0, 5, sl2);

        if(tp1[0] > 0 && tp2[0]  > 0 && sl1[0] > 0 &&  sl2[0] > 0)
         {
          if(tp2[0] > sl2[0])  // buy orders
           {
            const double ASK = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
            risk.SetStopLoss(ASK - sl1[0]);
            const double lot = (InpLoteType == Dinamico ? risk.GetLote(ORDER_TYPE_BUY, ASK, 0, 0) : InpLote);
            tradep.Buy(lot, _Symbol, ASK, sl1[0], tp2[0], "Order Block EA Buy");
           }
          else
            if(sl2[0] > tp2[0])  // sell orders
             {
              const double BID = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
              risk.SetStopLoss(sl1[0] - BID);
              const double lot = (InpLoteType == Dinamico ? risk.GetLote(ORDER_TYPE_SELL, BID, 0, 0) : InpLote);
              tradep.Sell(lot, _Symbol, BID, sl1[0], tp2[0], "Order Block EA Sell");
             }
         }
       }
     }
   }
 }

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction & trans,
                        const MqlTradeRequest & request,
                        const MqlTradeResult & result)
 {
  account_status.OnTradeTransactionEvent(trans);
 }

//+------------------------------------------------------------------+
//| Extra Functions                                                  |
//+------------------------------------------------------------------+
int GetMovingAverageIndex(long chart_id = 0)
 {
  int total_indicators = ChartIndicatorsTotal(chart_id, 0);
  for(int i = 0; i < total_indicators; i++)
   {
    string indicator_name = ChartIndicatorName(chart_id, 0, i);
    if(StringFind(indicator_name, "MA") >= 0)
      return i;
   }
  return -1;
 }
//+------------------------------------------------------------------+
int CreateIndicatorObHandle()
 {
//--- We configure the indicator parameters
  MqlParam param[19];

  param[0].type = TYPE_STRING;
  param[0].string_value = "::Shared Projects\\MQLArticles\\Ob\\Indicator\\OrderBlockIndPart2.ex5";

  param[1].type = TYPE_STRING;
  param[1].string_value = "--- Order Block Indicator settings ---";

  param[2].type = TYPE_BOOL;
  param[2].integer_value = false;

  param[3].type = TYPE_STRING;
  param[3].string_value = "-- Order Block --";

  param[4].type = TYPE_INT;
  param[4].integer_value = InpRangoUniversalBusqueda;

  param[5].type = TYPE_INT;
  param[5].integer_value = InpWidthOrderBlock;

  param[6].type = TYPE_BOOL;
  param[6].integer_value = InpBackOrderBlock;

  param[7].type = TYPE_BOOL;
  param[7].integer_value = InpFillOrderBlock;

  param[8].type = TYPE_COLOR;
  param[8].integer_value = InpColorOrderBlockBajista;

  param[9].type = TYPE_COLOR;
  param[9].integer_value = InpColorOrderBlockAlcista;

  param[10].type = TYPE_DOUBLE;
  param[10].double_value = InpTransparency;

  param[11].type = TYPE_STRING;
  param[11].string_value = "-- Strategy --";

  param[12].type = TYPE_INT;
  param[12].integer_value = InpTpSlStyle;

  param[13].type = TYPE_STRING;
  param[13].string_value = "- ATR";

  param[14].type = TYPE_DOUBLE;
  param[14].double_value = InpAtrMultiplier1;

  param[15].type = TYPE_DOUBLE;
  param[15].double_value = InpAtrMultiplier2;

  param[16].type = TYPE_STRING;
  param[16].string_value = "- POINT";

  param[17].type = TYPE_INT;
  param[17].integer_value = InpTpPoint;

  param[18].type = TYPE_INT;
  param[18].integer_value = InpSlPoint;

  order_block_indicator_handle = IndicatorCreate(_Symbol, InpTimeframeOrderBlock, IND_CUSTOM, ArraySize(param), param);

  if(order_block_indicator_handle == INVALID_HANDLE)
   {
    Print("The order blocks indicator is not available last error: ", _LastError);
    ExpertRemove();
    return INVALID_HANDLE;
   }

  ChartIndicatorAdd(0, 0, order_block_indicator_handle);
  return order_block_indicator_handle;
 }

//+------------------------------------------------------------------+
