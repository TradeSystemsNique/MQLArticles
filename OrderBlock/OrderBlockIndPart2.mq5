//+------------------------------------------------------------------+
//|                                           OrderBlockIndPart2.mq5 |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"

#define   Version "2.01"
#property version   Version 
#property indicator_chart_window
#property strict

#property indicator_buffers 6
#property indicator_plots 6

#property indicator_label1 "Buy"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrGreen
#property indicator_width1 1

#property indicator_label2 "Sell"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 1

#property indicator_label3 "Take Profit 1"
#property indicator_label4 "Take Profit 2"
#property indicator_label5 "Stop Loss 1"
#property indicator_label6 "Stop Loss 2"


enum ENUM_TP_SL_STYLE
 {
  ATR = 0, //Atr
  POINT = 1 //Points
 };


#include "Main.mqh"

sinput group "--- Order Block Indicator settings ---"
input bool enable_alerts = true; //Enable alerts ?

sinput group "-- Order Block --"
input          int  Universal_range_search = 500; //Range to find order blocks
input          int  Witdth_order_block = 1; //Order Blocks Width
input          bool Back_order_block = true; //Background for the rectangles of the order blocks?
input          bool Fill_order_block = true; //Fill order block?
input          color Color_Order_Block_Bajista = clrRed; //Bullish order block color
input          color Color_Order_Block_Alcista = clrGreen; //Bearish order block color
input          double transparecy = 0.3 ;//Transparency 0 - 1.0 (1.0 opaque and 0.0 transparent)

sinput group "-- Strategy --"
input          ENUM_TP_SL_STYLE tp_sl_style = POINT; //Type of TP and SL:

sinput group " ATR "
input          double Atr_Multiplier_1 = 1.5; //Atr multiplier 1 for the tp and sl
input          double Atr_Multiplier_2 = 2.0; //Atr multiplier 2 for the tp and sl

sinput group " POINT "
input          int TP_POINT = 500; //Takeprofit in points
input          int SL_POINT = 275; //Stoploss in points

//+------------------------------------------------------------------+
//|            Structures and Global Variables                       |
//+------------------------------------------------------------------+
struct OrderBlocks
 {
  datetime           time1;
  datetime           time2;
  double             price1;
  double             price2;
  string             name;
  bool               mitigated;
  bool               case_book;
 };

//--- Order Blocks Array
OrderBlocks bearish_ob[];
OrderBlocks bullish_ob[];
string pricetwo_eliminados_oba[];
string pricetwo_eliminados_obb[];

//--- Buffers
double  buy_buffer[];
double  sell_buffer[];
double tp1_buffer[];
double tp2_buffer[];
double sl1_buffer[];
double sl2_buffer[];

//--- Extra variables
datetime last_candle_time;
double ma[];
double atr[];

//--- Arrays longs para almacenar el volumen del book
long buy_volume[];
long sell_volume[];

//--- Flag to mark if the maket_book is used
bool use_market_book = true;

//--- Indicators handles
int Rsi_Handle; //Rsi handle
int hanlde_ma; //Ma Handle
int atr_i; //Atr Handle

//--- prefix for objects (this is to avoid conflicts with other order block indicators, or objects with the same name)
string code_obj; 

//--- Extra
color color_of_bullish_ob;
color color_of_bearish_ob;
#define ORDER_BLOCK_IND_NAME "OrderBlockIndicator"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//---
  MathSrand(GetTickCount());
  code_obj = StringFormat("%s_%s_%d_ob_indicator_",_Symbol,Version,MathRand()); 
//--- 
  color_of_bullish_ob = ApplyTransparency(Color_Order_Block_Alcista, transparecy);
  color_of_bearish_ob = ApplyTransparency(Color_Order_Block_Bajista, transparecy);

//---
  if(Universal_range_search < 40)
   {
    ob_logger.LogError(StringFormat("Very small search range = %d", Universal_range_search), ORDER_BLOCK_IND_NAME);
    return (INIT_PARAMETERS_INCORRECT);
   }

//---
  if(Universal_range_search  >= Bars(_Symbol, _Period) + 31)
   {
    ob_logger.LogError(StringFormat("The data available for the indicator calculations are less than the calculation range %d", Bars(_Symbol, _Period) + 20, Universal_range_search), ORDER_BLOCK_IND_NAME);
    return (INIT_PARAMETERS_INCORRECT);
   }

//---
  int max_attempts = 1000; // Maximum attempts (500 x 10ms = 5 seconds)
  while(!SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_SYNCHRONIZED) && max_attempts-- > 0)
    Sleep(10);

  if(max_attempts <= 1)
   {
    ob_logger.LogError("The data required for the indicator to function correctly is not synchronized.", ORDER_BLOCK_IND_NAME);
    return INIT_FAILED;
   }

  datetime dummy[];
  CopyTime(_Symbol, _Period, 0, MathMax(Bars(_Symbol, _Period) - 10, 100), dummy);
  Sleep(100);

//--- Atr
  ResetLastError();
  atr_i = iATR(_Symbol, PERIOD_CURRENT, 14);
  if(atr_i == INVALID_HANDLE)
   {
    ob_logger.LogError(StringFormat("The atr handle is invalid, last error descripcion: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
    return(INIT_FAILED);
   }

//--- Ma
  ResetLastError();
  hanlde_ma = iMA(_Symbol, _Period, 30, 0, MODE_EMA, PRICE_CLOSE);
  if(hanlde_ma == INVALID_HANDLE)
   {
    ob_logger.LogError(StringFormat("The ema indicator is not available. last error descripcion: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
    return(INIT_FAILED);
   }

//--- Market Book
  ResetLastError();
  if(!MarketBookAdd(_Symbol))
   {
    use_market_book = false;
    ob_logger.LogError(StringFormat("The order book could not be opened. last error descripcion: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
   }
  else
    ob_logger.LogInfo(StringFormat("Market Book available for the symbol: %s", _Symbol), ORDER_BLOCK_IND_NAME);

//---
  ArrayResize(bearish_ob, 0);
  ArrayResize(bullish_ob, 0);
  ArraySetAsSeries(ma, true);
  ArraySetAsSeries(atr, true);
  string short_name = StringFormat("Order Block Indicator[%d]", Universal_range_search);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- Plots
  PlotIndexSetString(0, PLOT_LABEL, "Buy");
  PlotIndexSetInteger(0, PLOT_ARROW, 233);

  PlotIndexSetString(1, PLOT_LABEL, "Sell");
  PlotIndexSetInteger(1, PLOT_ARROW, 234);

  PlotIndexSetString(2, PLOT_LABEL, "Take Profit 1");
  PlotIndexSetString(3, PLOT_LABEL, "Take Profit 2");
  PlotIndexSetString(4, PLOT_LABEL, "Stop Loss 1");
  PlotIndexSetString(5, PLOT_LABEL, "Stop Loss 2");

//--- Buffers
  SetIndexBuffer(0, buy_buffer, INDICATOR_DATA);
  SetIndexBuffer(1, sell_buffer, INDICATOR_DATA);
  SetIndexBuffer(2, tp1_buffer, INDICATOR_DATA);
  SetIndexBuffer(3, tp2_buffer, INDICATOR_DATA);
  SetIndexBuffer(4, sl1_buffer, INDICATOR_DATA);
  SetIndexBuffer(5, sl2_buffer, INDICATOR_DATA);

//---
  ArraySetAsSeries(buy_buffer, true);
  ArraySetAsSeries(sell_buffer, true);
  ArrayFill(buy_buffer, 0, 0, EMPTY_VALUE);
  ArrayFill(sell_buffer, 0, 0, EMPTY_VALUE);

//---
  ArraySetAsSeries(tp1_buffer, true);
  ArraySetAsSeries(tp2_buffer, true);
  ArrayFill(tp1_buffer, 0, 0, EMPTY_VALUE);
  ArrayFill(tp2_buffer, 0, 0, EMPTY_VALUE);

//---
  ArraySetAsSeries(sl1_buffer, true);
  ArraySetAsSeries(sl2_buffer, true);
  ArrayFill(sl1_buffer, 0, 0, EMPTY_VALUE);
  ArrayFill(sl2_buffer, 0, 0, EMPTY_VALUE);

//---
  ArrayResize(buy_volume, 1);
  ArrayResize(sell_volume, 1);

//---
  buy_volume[0] = 0.0;
  sell_volume[0] = 0.0;

//---
  return(INIT_SUCCEEDED);
 }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
 {
//---
  static int counter = 0;

  if(rates_total > prev_calculated)
   {
    counter++;
    if(last_candle_time != iTime(_Symbol, PERIOD_D1,  0))
     {
      Eliminar_Objetos();
      ArrayFree(bearish_ob);
      ArrayFree(bullish_ob);
      last_candle_time = iTime(_Symbol, PERIOD_D1,  0);
     }

    if(counter > 1  && use_market_book == true)
     {
      if(ArraySize(buy_volume) > 4 && ArraySize(sell_volume) > 4)
       {
        if(buy_volume[3] == 0 && sell_volume[3] == 0 &&
           buy_volume[2] == 0 && sell_volume[2] == 0 &&
           buy_volume[1] == 0 && sell_volume[1] == 0)
         {
          use_market_book = false;
          ob_logger.LogWarning("Disabling use of the market book because there is no data available.", ORDER_BLOCK_IND_NAME);
         }
       }

      if(ArraySize(buy_volume) >= 30)
       {
        ArrayResize(buy_volume, 30); // Ensure that the size of buy_volume does not exceed 30
        ArrayResize(sell_volume, 30); // Ensure that the size of sell_volume does not exceed 30
       }

      ArrayResize(buy_volume, ArraySize(buy_volume) + 1);
      ArrayResize(sell_volume, ArraySize(sell_volume) + 1);

      for(int i = ArraySize(buy_volume) - 1; i > 0; i--)
       {
        buy_volume[i] = buy_volume[i - 1];
        sell_volume[i] = sell_volume[i - 1];
       }

      buy_volume[0] = 0;
      sell_volume[0] = 0;
     }
   }

//---
  if(rates_total > prev_calculated)
   {
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(tick_volume, true);

    if(prev_calculated == 0)
     {
      ResetLastError();
      if(CopyBuffer(atr_i, 0, 0, Universal_range_search + 10, atr) < 1)
       {
        ob_logger.LogError(StringFormat("Could not copy data from the ATR indicator, last error description: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
        return rates_total;
       }

      ResetLastError();
      if(CopyBuffer(hanlde_ma, 0, 0, 5, ma) < 5)
       {
        ob_logger.LogError(StringFormat("Could not copy data from the Ma indicator, last error description: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
        return rates_total;
       }
     }
    else
     {
      ResetLastError();
      if(CopyBuffer(atr_i, 0, 0, 10, atr) < 10)
       {
        ob_logger.LogError(StringFormat("Could not copy data from the ATR indicator, last error description: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
        return rates_total;
       }

      ResetLastError();
      if(CopyBuffer(hanlde_ma, 0, 0, 5, ma) < 5)
       {
        ob_logger.LogError(StringFormat("Could not copy data from the Ma indicator, last error description: %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
        return rates_total;
       }
     }


    //----------------- Bullish order blocks
    OrderBlocks newVela_Order_block_alcista;
    OrderBlocks newVela_Order_block_volumen;
    OrderBlocks newVela_Order_block_Book;

    int inicio = prev_calculated == 0 ? Universal_range_search : 6;

    for(int i = inicio  ; i  > 5  ; i--)
     {
      if(i + 3 > ArraySize(high)  || i + 3 > ArraySize(atr))
        continue;
      if(i < 0)
        continue;

      //--- Declaracion de variables
      int one_vela = i ;
      int two_candles_previous_to_one_candle = i + 2;
      int one_candle_before_one_candle = one_vela + 1;
      int two_vela = one_vela - 1;
      int tree_vela = one_vela - 2;
      int four_vela = one_vela - 3;
      double body1 = close[one_vela] - open[one_vela];
      double body2 = close[two_vela] - open[two_vela];
      double body3 = close[tree_vela] - open[two_vela];
      long Volumen_one_vela = tick_volume[one_vela];
      long Volumen_two_vela = tick_volume[two_vela];
      long volumen_one_candle_before_one_candle = tick_volume[one_candle_before_one_candle];

      bool case_bullish_orderblock_normal = false; //Flag indicating that the order block has been obtained in the "normal" case
      bool case_orderblock_vol = false; //Flag indicating that the order block has been obtained by the "volume" case

      //--- Conditions
      bool IsCorrectCandleForNormalCase =  close[one_vela] > open[one_vela] && close[two_vela] > open[two_vela]
                                         && close[tree_vela] > open[tree_vela] && close[four_vela] > open[four_vela];

      bool  IsHammerCandle = open[one_vela] - low[one_vela] > close[one_vela] - open[one_vela];

      bool fuerte_movimiento_alcista = close[one_vela + 2] > open[one_vela + 2] &&
                                       close[one_vela + 1] > open[one_vela + 1] &&
                                       close[one_vela] > open[one_vela] &&
                                       close[two_vela] > open[two_vela] &&
                                       close[tree_vela] > open[tree_vela] &&
                                       close[four_vela] > open[four_vela];

      bool atr_case = atr[two_candles_previous_to_one_candle] > atr[one_vela] && atr[two_vela] > atr[one_vela] && atr[two_vela] > atr[two_candles_previous_to_one_candle] && close[one_vela] > open[one_vela]
                      && close[four_vela] > open[four_vela] && close[tree_vela] > open[tree_vela]; //case by atr (included in normal)


      if((IsCorrectCandleForNormalCase && ((low[two_vela] > ((body1 * 0.5) + open[one_vela]) && ((body2 * 0.4) + open[two_vela]) > high[one_vela]) || IsHammerCandle)
          && low[tree_vela] > ((body2 * 0.25) + open[two_vela])) || fuerte_movimiento_alcista || atr_case ) //Here at the beginning we look for the highlights not to exceed important points
       {
        int furthestAlcista = FindFurthestAlcista(time[one_vela], 20, _Period, _Symbol);

        if(furthestAlcista > 0)
         {
          datetime time1 = time[furthestAlcista];
          double price2 = open[furthestAlcista];
          double price1 = low[furthestAlcista];
          newVela_Order_block_alcista.price1 = price1;
          newVela_Order_block_alcista.time1 = time1;
          newVela_Order_block_alcista.price2 = price2;
          newVela_Order_block_alcista.case_book = false;
          case_bullish_orderblock_normal = true;
         }
        else
          case_bullish_orderblock_normal = false;
       }

      //--- Verify that the case is met by volume
      bool CorrectCandleForVolumeCase = close[one_vela] > open[one_vela]  && close[two_vela] > open[two_vela];
      bool CorrectVolume = Volumen_one_vela  > Volumen_two_vela && Volumen_one_vela > volumen_one_candle_before_one_candle;
      bool case_vol_2 = (tick_volume[one_vela] > volumen_one_candle_before_one_candle && tick_volume[two_vela] > tick_volume[one_vela] &&
                         open[tree_vela] < close[tree_vela] && open[four_vela] < close[four_vela]);

      //---
      if((CorrectVolume  && CorrectCandleForVolumeCase 
          && ((low[two_vela] > ((body1 * 0.5) + open[one_vela]) && ((body2 * 0.6) + open[two_vela]) > high[one_vela]) || IsHammerCandle == true)
          && high[tree_vela] > open[two_vela]) || case_vol_2 == true)
       {
        int furthestAlcista = FindFurthestAlcista(time[one_vela], 20, _Period, _Symbol);
        if(furthestAlcista > 0)
         {
          datetime time1 = time[furthestAlcista];
          double price2 = open[furthestAlcista];
          double price1 = low[furthestAlcista];
          newVela_Order_block_volumen.price1 = price1;
          newVela_Order_block_volumen.time1 = time1;
          newVela_Order_block_volumen.case_book = false;
          newVela_Order_block_volumen.price2 = price2;
          case_orderblock_vol = true;
         }
        else
          case_orderblock_vol = false;
       }

      if(case_bullish_orderblock_normal  && IsBullishObMitigated(newVela_Order_block_alcista.price2, low, time, newVela_Order_block_alcista.time1, time[0]) == 0)
       {
        newVela_Order_block_alcista.mitigated = false;
        newVela_Order_block_alcista.name =  code_obj + "bull_" + TimeToString(newVela_Order_block_alcista.time1) ;
        AddArray(bullish_ob, newVela_Order_block_alcista);
       }
      if(case_orderblock_vol && IsBullishObMitigated(newVela_Order_block_volumen.price2, low, time, newVela_Order_block_volumen.time1, time[0]) == 0)
       {
        newVela_Order_block_volumen.mitigated = false;
        newVela_Order_block_volumen.name =  code_obj + "bull_"  + TimeToString(newVela_Order_block_volumen.time1) ;
        AddArray(bullish_ob, newVela_Order_block_volumen);
       }
     }

    //--- Check the case on MarketBook
    if(ArraySize(buy_volume) >= 5 && ArraySize(sell_volume) >= 5 && use_market_book)
     {
      const double ratio = 1.4;
      bool case_book = buy_volume[3] > buy_volume[4] * ratio && buy_volume[3] > buy_volume[2] * ratio &&
                       buy_volume[3] > sell_volume[4] * ratio && buy_volume[3] > sell_volume[2] * ratio;

      double body_tree =  close[3] - open[3];

      if(low[2] > ((body_tree * 0.5) + open[3]) && high[3] < close[2] &&
         close[3] > open[3] && close[2] > open[2] && close[1] > open[1] && case_book)
       {
        int furthestAlcista = FindFurthestAlcista(time[3], 20, _Period, _Symbol);
        if(furthestAlcista > 0)
         {
          datetime time1 = time[furthestAlcista];
          double price2 = open[furthestAlcista];
          double price1 = low[furthestAlcista];
          newVela_Order_block_Book.price1 = price1;
          newVela_Order_block_Book.time1 = time1;
          newVela_Order_block_Book.price2 = price2;
          newVela_Order_block_Book.case_book = true;
          newVela_Order_block_Book.mitigated = false;
          newVela_Order_block_Book.name = code_obj + "bull_" + TimeToString(newVela_Order_block_Book.time1);
          AddArray(bullish_ob, newVela_Order_block_Book);
         }
       }
     }

    //---
    static bool buscar_oba = true;
    static datetime time_a = 0;
    string curr_elimiandor_oba[];

    for(int i = 0; i < ArraySize(bullish_ob); i++)
     {
      datetime mitigadoTime = IsBullishOrderBlockMitigated(bullish_ob[i], bullish_ob[i].time1);

      if(!bullish_ob[i].mitigated)
       {
        if(ObjectFind(ChartID(), bullish_ob[i].name) < 0)
         {

          const static string tools[2] = { "Order Block Alcista", "Order Block Alcista Book"  };
          RectangleCreate(ChartID(), bullish_ob[i].name, 0, bullish_ob[i].time1, bullish_ob[i].price1,
                          time[0], bullish_ob[i].price2, color_of_bullish_ob, Witdth_order_block, Fill_order_block, Back_order_block, STYLE_SOLID, false, tools[int(bullish_ob[i].case_book)]);
         }
        else
          ObjectSetInteger(ChartID(), bullish_ob[i].name, OBJPROP_TIME, 1, time[0]); //On the contrary, if the object exists, all we will do is update it at the current time using anchor point 1
       }
      else
       {
        if(enable_alerts)
          Alert("The bullish order block is being mitigated: ", TimeToString(bullish_ob[i].time1));

        AddArrayNoVerification(pricetwo_eliminados_oba, bullish_ob[i].name);
        AddArrayNoVerification(curr_elimiandor_oba, bullish_ob[i].name);

        if(buscar_oba == true)
         {
          buscar_oba = false;
          time_a = iTime(_Symbol, _Period, 1);
         }

       }
     }

    for(int i = 0; i < ArraySize(curr_elimiandor_oba) ; i++)
      DeleteArrayBiName(bullish_ob, curr_elimiandor_oba[i]);

    if(buscar_oba == false && time_a > 0)
     {
      double close_ = NormalizeDouble(close[1], _Digits);
      datetime max_time_espera = time_a + (PeriodSeconds() * 7); //Maximum wait 7 candles to confirm the break of the moving average
      if(close_ > ma[1] && time[0] <= max_time_espera)
       {
        double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
        double tp1;
        double tp2;
        double sl1;
        double sl2;
        GetTP_SL(ask, POSITION_TYPE_BUY, tp1, tp2, sl1, sl2);
        DrawTP_SL(tp1, tp2, sl1, sl2);
        tp1_buffer[0] = tp1;
        tp2_buffer[0] = tp2;
        sl1_buffer[0] = sl1;
        sl2_buffer[0] = sl2;
        buy_buffer[0] = ask - atr[0] * 1.3;
        time_a = 0;
        buscar_oba = true;
       }
      if(time[0] > max_time_espera)
       {
        time_a = 0;
        buscar_oba = true;
       }
     }

    //----------------- Bearish order blocks
    OrderBlocks newVela_Order_Block_bajista;
    OrderBlocks newVela_Order_Block_bajista_2;
    OrderBlocks newVela_Order_block_Book_bajista;

    for(int i = inicio ; i > 5  ; i--)
     {
      if(i + 3 > ArraySize(high) || i + 3 > ArraySize(atr))
        continue;

      if(i < 0)
        continue;

      //-------- Variable Declaration --------------------------------------------//
      // Update candlestick indices
      int one_vela = i ; //vela central
      int one_candle_before_one_candle = one_vela + 1;
      int two_vela = one_vela - 1;
      int tree_vela = one_vela - 2;
      int two_candles_previous_to_one_candle = one_vela + 2;
      double body1 = open[one_vela] - close[one_vela];
      double body2 = open[two_vela] - close[two_vela];
      double body3 = open[tree_vela] - close[tree_vela];
      long Volumen_one_vela = tick_volume[one_vela];
      long Volumen_two_vela = tick_volume[two_vela];
      long volumen_one_candle_before_one_candle = tick_volume[one_candle_before_one_candle];
      bool case_OrderBlockBajista_normal = false;
      bool case_OrderBlockBajista_volumen = false;

      bool IsCorrectCandleForNormalCase = close[one_vela] < open[one_vela]  &&
                                        close[two_vela] < open[two_vela]  &&
                                        close[tree_vela] < open[tree_vela]  &&
                                        close[one_vela - 3] < open[one_vela - 3];

      bool a = atr[two_candles_previous_to_one_candle] > atr[one_vela] && atr[two_vela] > atr[one_vela] && atr[two_vela] > atr[two_candles_previous_to_one_candle] && IsCorrectCandleForNormalCase;


      bool StrongBearishMovement = close[one_vela + 2] < open[one_vela + 2] && close[one_vela + 1] < open[one_vela + 1] && close[one_vela] < open[one_vela] &&
                                       close[two_vela] < open[two_vela] && close[tree_vela] < open[tree_vela] && close[one_vela - 3] <= open[one_vela - 3];

      if((IsCorrectCandleForNormalCase == true && high[two_vela] < ((body1 * 0.70) + close[one_vela]) && ((body2 * 0.4) + close[two_vela]) < low[one_vela] && high[tree_vela] < high[two_vela])
         || a || StrongBearishMovement)
       {
        int furthestBajista = FindFurthestBajista(time[one_vela], 20, _Period, _Symbol);
        if(furthestBajista != -1)
         {
          datetime time1 = time[furthestBajista];
          double price1 = close[furthestBajista];
          double price2 = low[furthestBajista];
          newVela_Order_Block_bajista.price1 = price1;
          newVela_Order_Block_bajista.time1 = time1;
          newVela_Order_Block_bajista.case_book = false;
          newVela_Order_Block_bajista.price2 = price2 ;
         }
        else
          case_OrderBlockBajista_normal = false;
       }

      bool CorrectCandleForVolumeCase = close[one_vela] < open[one_vela]  &&  close[two_vela] < open[two_vela];
      bool CorrectVolume = Volumen_one_vela  > Volumen_two_vela && Volumen_one_vela > volumen_one_candle_before_one_candle;
      bool case_vol_2 = tick_volume[one_vela] > volumen_one_candle_before_one_candle && tick_volume[two_vela] > tick_volume[one_vela] && open[tree_vela] > close[tree_vela] && open[one_vela - 3] > close[one_vela - 3];

      if((CorrectVolume == true && CorrectCandleForVolumeCase == true && high[two_vela] < ((body1 * 0.5) + close[one_vela])
          && ((body2 * 0.5) + close[two_vela]) < low[one_vela]) || case_vol_2 == true) // verificamos si se cumple
       {
        int furthestBajista = FindFurthestBajista(time[one_vela], 20, _Period, _Symbol);
        if(furthestBajista > 0)
         {
          datetime time1 = time[furthestBajista];
          double price1 = close[furthestBajista];
          double price2 = low[furthestBajista];
          newVela_Order_Block_bajista_2.price1 = price1;
          newVela_Order_Block_bajista_2.time1 = time1;
          newVela_Order_Block_bajista_2.price2 = price2 ;
          newVela_Order_Block_bajista_2.case_book = false;
          case_OrderBlockBajista_volumen = true;
         }
        else
          case_OrderBlockBajista_volumen = false;
       }

      if(case_OrderBlockBajista_normal == true  && mitigado_bajista(newVela_Order_Block_bajista.price2,  high, time, newVela_Order_Block_bajista.time1, time[0]) == 0)
       {
        newVela_Order_Block_bajista.mitigated = false;
        newVela_Order_Block_bajista.name = code_obj + "bear_" + TimeToString(newVela_Order_Block_bajista.time1);
        AddArray(bearish_ob,  newVela_Order_Block_bajista); //we add the structure to the array
       }
      if(case_OrderBlockBajista_volumen == true   && mitigado_bajista(newVela_Order_Block_bajista_2.price2, high, time, newVela_Order_Block_bajista_2.time1, time[0]) == 0)
       {
        newVela_Order_Block_bajista_2.mitigated = false;
        newVela_Order_Block_bajista_2.name = code_obj + "bear_" +  TimeToString(newVela_Order_Block_bajista_2.time1);
        AddArray(bearish_ob,  newVela_Order_Block_bajista_2); //we add the structure to the array
       }
     }

    if(ArraySize(buy_volume) >= 5 && ArraySize(sell_volume) >= 5 && use_market_book == true)
     {
      const double ratio = 1.4;
      bool case_book = sell_volume[3] > buy_volume[4] * ratio && sell_volume[3] > buy_volume[2] * ratio &&
                       sell_volume[3] > sell_volume[4] * ratio && sell_volume[3] > sell_volume[2] * ratio;

      double body_tree =   open[3] - close[3];
      if(high[2] < (open[3] - (body_tree * 0.5)) && low[3] > close[2] && close[3] < open[3] && close[2] < open[2] && close[1] < open[1] && case_book)
       {
        int furthestBajista = FindFurthestBajista(time[3], 20, _Period, _Symbol);
        if(furthestBajista  > 0)
         {
          datetime time1 = time[furthestBajista];
          double price1 = close[furthestBajista];
          double price2 = low[furthestBajista];
          newVela_Order_block_Book_bajista.price1 = price1;
          newVela_Order_block_Book_bajista.time1 = time1;
          newVela_Order_block_Book_bajista.case_book = true;
          newVela_Order_block_Book_bajista.price2 = price2;
          newVela_Order_block_Book_bajista.mitigated = false;
          newVela_Order_block_Book_bajista.name = code_obj + "bear_" + TimeToString(newVela_Order_block_Book_bajista.time1);
          AddArray(bearish_ob, newVela_Order_block_Book_bajista);
         }
       }
     }

    //--- Initial declaration of variables
    static bool buscar_obb = true; //Flag indicating whether a bearish order block is being sought
    static datetime time_b = 0; //Time in which the bearish order block was mitigated (to be able to schedule a maximum wait)
    string curr_elimiandor_obb[]; //Array with the names of the order blocks that will be removed from the bearish_ob array

    for(int i = 0; i < ArraySize(bearish_ob); i++)
     {
      datetime mitigadoTime = esOb_mitigado_array_bajista(bearish_ob[i], bearish_ob[i].time1);

      if(bearish_ob[i].mitigated == false) //if it has not been mitigated
       {
        if(ObjectFind(ChartID(), bearish_ob[i].name) < 0) //If the object does not exist, we create it
         {
          const static string tools[2] = { "Order Block Bajista", "Order Block Bajista Book"};
          RectangleCreate(ChartID(), bearish_ob[i].name, 0, bearish_ob[i].time1, bearish_ob[i].price1,
                          time[0], bearish_ob[i].price2, color_of_bearish_ob, Witdth_order_block, Fill_order_block, Back_order_block, STYLE_SOLID, false, tools[int(bearish_ob[i].case_book)]);
         }
        else //If it exists, we update it (we only move anchor point 1)
          ObjectSetInteger(ChartID(), bearish_ob[i].name, OBJPROP_TIME, 1, time[0]);
       }
      else
       {
        //A bearish order block has been mitigated
        if(enable_alerts)
          Alert("The bearish order block is being mitigated: ", TimeToString(bearish_ob[i].time1)); //We print an alert
        AddArrayNoVerification(pricetwo_eliminados_obb, bearish_ob[i].name); //To be able to remove the rectangle from the order block we save its name
        AddArrayNoVerification(curr_elimiandor_obb, bearish_ob[i].name); //We add to the string array so that it is removed from the main array

        if(buscar_obb == true) //If we search for obb, it means that we are searching for a signal, so we initialize the start time time_b with the current one, (this is to calculate the maximum wait)
         {
          time_b = iTime(_Symbol, _Period, 0);
          buscar_obb = false;
         }

       }
     }

    for(int i = 0; i < ArraySize(curr_elimiandor_obb) ; i++)
      DeleteArrayBiName(bearish_ob, curr_elimiandor_obb[i]); //We remove the indicated name from the array (name)

    if(buscar_obb == false && time_b  > 0)
     {
      double close_ = NormalizeDouble(close[1], _Digits); //We normalize the price
      datetime max_time_espera = time_b + (PeriodSeconds() * 5); //Maximum wait 5 candles to confirm the break of the moving average
      if(close_ < ma[1] && time[0] <= max_time_espera) //We verify that the previous close is lower than the value of the previous EMA and that the last opening time is less than the maximum wait
       {
        double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits); //Obtenmos el bid
        double tp1, tp2, sl1, sl2;

        GetTP_SL(bid, POSITION_TYPE_SELL, tp1, tp2, sl1, sl2); //We get the tp, sl
        DrawTP_SL(tp1, tp2, sl1, sl2); //We draw

        //--- Let's assign to the buffers
        tp1_buffer[0] = tp1;
        tp2_buffer[0] = tp2;
        sl1_buffer[0] = sl1;
        sl2_buffer[0] = sl2;

        //---
        sell_buffer[0] = bid + atr[0] * 1.3;

        //--- We reset the variables
        time_b = 0;
        buscar_obb = true;
       }
      if(time[0] > max_time_espera) //If the maximum wait is exceeded, we also restart and look for another mitigated bearish order block.
       {
        time_b = 0;
        buscar_obb = true;
       }
     }
   }

//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
//---
  Eliminar_Objetos();
  ArrayFree(bearish_ob);
  ArrayFree(bullish_ob);

  if(atr_i  != INVALID_HANDLE)
    IndicatorRelease(atr_i);
  if(hanlde_ma != INVALID_HANDLE)
    IndicatorRelease(hanlde_ma);

  ResetLastError();
//---
  if(MarketBookRelease(_Symbol)) //Verificamos si el cierre fue exitoso
    ob_logger.LogInfo("Market book closed successfully", ORDER_BLOCK_IND_NAME);
  else
    ob_logger.LogWarning(StringFormat("Order book not closed successfully, last error description = %s", ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
 }

//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
 {
  if(symbol != _Symbol || use_market_book == false)
    return;

  MqlBookInfo book_info[];
  bool book_count = MarketBookGet(_Symbol, book_info);

  if(book_count == true)
   {
    for(int i = 0; i < ArraySize(book_info); i++)
     {
      if(book_info[i].type == BOOK_TYPE_BUY  || book_info[i].type ==  BOOK_TYPE_BUY_MARKET)
        buy_volume[0] += book_info[i].volume;
      else
        if(book_info[i].type == BOOK_TYPE_SELL || book_info[i].type == BOOK_TYPE_SELL_MARKET)
          sell_volume[0] += book_info[i].volume;
     }
   }
  else
   {
    ob_logger.LogWarning("No data has been obtained from the Market Book.", ORDER_BLOCK_IND_NAME);
   }
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
 {
  if(id == CHARTEVENT_CHART_CHANGE && lparam == 3)
   {
    color_of_bullish_ob = ApplyTransparency(Color_Order_Block_Alcista, transparecy);
    color_of_bearish_ob = ApplyTransparency(Color_Order_Block_Bajista, transparecy);
    ModificarColor();
   }
 }


//+------------------------------------------------------------------+
//| Array                                                            |
//+------------------------------------------------------------------+
template <typename S>
bool AddArray(S &Array[], const S &Value)
 {
  for(int i = 0 ; i < ArraySize(Array) ; i++)
   {
    if(Array[i].name == Value.name)
      return false;
   }
  ArrayResize(Array, Array.Size() + 1);
  Array[Array.Size() - 1] = Value;
  return true;
 }

template <typename X>
void AddArrayNoVerification(X &array[], const X &value)
 {
  ArrayResize(array, array.Size() + 1);
  array[array.Size() - 1] = value;
 }

template<typename T>
bool DeleteArrayBiName(T &array[], const string targetName)
 {
  int size = ArraySize(array);
  int index = -1;


  for(int i = 0; i < size; i++)
   {
    if(array[i].name == targetName)
     {
      index = i;
     }
    if(index != -1 && i < size - 1)
     {
      array[i] = array[i + 1]; // Move the elements
     }
   }

  if(index == -1)
    return false;

  if(size > 1)
    ArrayResize(array, size - 1);
  else
    ArrayFree(array); // If the array had only one element, it is completely freed

  return true;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime  IsBullishObMitigated(double price, const double &lowArray[], const  datetime &Time[], datetime start, datetime end)
 {
  int startIndex = iBarShift(_Symbol, PERIOD_CURRENT, start);
  int endIndex = iBarShift(_Symbol, PERIOD_CURRENT, end);

  NormalizeDouble(price, _Digits);
  for(int i = startIndex - 2 ; i >= endIndex + 1 ; i--)
   {
    if(price > lowArray[i])
     {
      return Time[i];//if it finds that there was, it returns the time of the candle where the mitigation occurred
     }
   }

  return 0;
 }

//+------------------------------------------------------------------+
datetime  mitigado_bajista(double price, const  double &highArray[], const datetime &Time[], datetime start, datetime end)
 {
  int startIndex = iBarShift(_Symbol, PERIOD_CURRENT, start);
  int endIndex = iBarShift(_Symbol, PERIOD_CURRENT, end);
  NormalizeDouble(price, _Digits);
  for(int i = startIndex - 2 ; i >= endIndex + 1 ; i--)
   {
    if(highArray[i] > price)
     {
      return Time[i]; ///if it finds that there was, it returns the time of the candle where the mitigation occurred
     }
   }
  return 0;
 }

//+------------------------------------------------------------------+
datetime IsBullishOrderBlockMitigated(OrderBlocks &newblock, datetime end)
 {
  int endIndex = iBarShift(_Symbol, PERIOD_CURRENT, end) - 2;
  if(endIndex < 0)
    return 0;

  for(int i = 0 ; i <  endIndex; i++)
   {
    double low = iLow(_Symbol, PERIOD_CURRENT, i);
    if(newblock.price2 >= low)
     {
      newblock.mitigated = true;
      newblock.time2 = iTime(_Symbol, _Period, i);
      return newblock.time2;//returns the time of the candle found
     }
   }
  return 0;// not mitigated so far
 }
//+------------------------------------------------------------------+
datetime esOb_mitigado_array_bajista(OrderBlocks &newblock, datetime end)
 {
  int endIndex = iBarShift(_Symbol, PERIOD_CURRENT, end) - 2;
  if(endIndex < 0)
    return 0;

  for(int i = 0 ; i <  endIndex ; i++)
   {
    double high = iHigh(_Symbol, PERIOD_CURRENT, i);
    if(high >= newblock.price2)
     {
      newblock.mitigated = true;
      newblock.time2 = iTime(_Symbol, _Period, i);
      return newblock.time2;
     }
   }
  return 0; // not mitigated so far
 }
//+------------------------------------------------------------------+
int FindFurthestBajista(datetime start, int numVelas, ENUM_TIMEFRAMES timeframe, string symbol)
 {
  int startVela = iBarShift(symbol, timeframe, start);

  for(int i = startVela + 1, c = 0; i <= startVela + numVelas; i++, c++)
   {
    if(iClose(symbol, timeframe, i) > iOpen(symbol, timeframe, i))
      return startVela + 1 + c;
   }

  return -1;
 }

//+------------------------------------------------------------------+
int FindFurthestAlcista(datetime start, int numVelas, ENUM_TIMEFRAMES timeframe, string symbol)
 {
  int startVela = iBarShift(symbol, timeframe, start);

  for(int i = startVela + 1, c = 0; i <= startVela + numVelas; i++, c++)
   {
    if(iClose(symbol, timeframe, i) < iOpen(symbol, timeframe, i))
      return startVela + 1 + c;
   }

  return -1;
 }

//+------------------------------------------------------------------+
//| TP-SL                                                            |
//+------------------------------------------------------------------+
void GetTP_SL(double price_open_position, ENUM_POSITION_TYPE type, double &tp1, double &tp2, double &sl1, double &sl2)
 {
  if(CopyBuffer(atr_i, 0, 0, 1, atr) < 1)
   {
    return;
   }

  if(tp_sl_style == ATR)
   {
    if(type == POSITION_TYPE_BUY)
     {
      sl1 = price_open_position - (atr[0] * Atr_Multiplier_1);
      sl2 = price_open_position - (atr[0] * Atr_Multiplier_2);
      tp1 = price_open_position + (atr[0] * Atr_Multiplier_1);
      tp2 = price_open_position + (atr[0] * Atr_Multiplier_2);
     }
    if(type == POSITION_TYPE_SELL)
     {
      sl1 = price_open_position + (atr[0] * Atr_Multiplier_1);
      sl2 = price_open_position + (atr[0] * Atr_Multiplier_2);
      tp1 = price_open_position - (atr[0] * Atr_Multiplier_1);
      tp2 = price_open_position - (atr[0] * Atr_Multiplier_2);
     }
   }
  else
    if(tp_sl_style == POINT)
     {
      if(type == POSITION_TYPE_BUY)
       {
        sl1 = price_open_position - (SL_POINT * _Point);
        sl2 = price_open_position - (SL_POINT * _Point * 2);
        tp1 = price_open_position + (TP_POINT * _Point);
        tp2 = price_open_position + (TP_POINT * _Point * 2);
       }
      if(type == POSITION_TYPE_SELL)
       {
        sl1 = price_open_position + (SL_POINT * _Point);
        sl2 = price_open_position + (SL_POINT * _Point * 2);
        tp1 = price_open_position - (TP_POINT * _Point);
        tp2 = price_open_position - (TP_POINT * _Point * 2);
       }
     }
 }

//+------------------------------------------------------------------+
void DrawTP_SL(double tp1, double tp2, double sl1, double sl2)
 {
  string  curr_time = "ENTRY" + TimeToString(iTime(_Symbol, _Period, 0));
  datetime extension_time = iTime(_Symbol, _Period, 0) + (PeriodSeconds(PERIOD_CURRENT) * 15);
  datetime   text_time = extension_time + (PeriodSeconds(PERIOD_CURRENT) * 2);
// Print("SL1: " , sl1 , " SL2: " , sl2 , " TP1: " , tp1 , " TP2: " , tp2);
  TrendCreate(0, curr_time + " TP1", 0, iTime(_Symbol, _Period, 0), tp1, extension_time, tp1, clrGreen, STYLE_DOT, 1, true, false);
  TextCreate(0, curr_time + " TP1 - Text", 0, text_time, tp1, "TP1", "Arial", 8, clrGreen, 0.0, ANCHOR_CENTER);
  TrendCreate(0, curr_time + " TP2", 0, iTime(_Symbol, _Period, 0), tp2, extension_time, tp2, clrGreen, STYLE_DOT, 1, true, false);
  TextCreate(0, curr_time + " TP2 - Text", 0, text_time, tp2, "TP2", "Arial", 8, clrGreen, 0.0, ANCHOR_CENTER);
  TrendCreate(0, curr_time + " SL1", 0, iTime(_Symbol, _Period, 0), sl1, extension_time, sl1, clrRed, STYLE_DOT, 1, true, false);
  TextCreate(0, curr_time + " SL1 - Text", 0, text_time, sl1, "SL1", "Arial", 8, clrRed, 0.0, ANCHOR_CENTER);
  TrendCreate(0, curr_time + " SL2", 0, iTime(_Symbol, _Period, 0), sl2, extension_time, sl2, clrRed, STYLE_DOT, 1, true, false);
  TextCreate(0, curr_time + " SL2 - Text", 0, text_time, sl2, "SL2", "Arial", 8, clrRed, 0.0, ANCHOR_CENTER);
 }

//+------------------------------------------------------------------+
//| OrderBlocks                                                      |
//+------------------------------------------------------------------+
void ModificarColor()
 {
  for(int i = 0; i < ArraySize(bullish_ob) ; i++)
    ObjectSetInteger(0, bullish_ob[i].name, OBJPROP_COLOR, color_of_bullish_ob);

  for(int i = 0; i < ArraySize(bearish_ob) ; i++)
    ObjectSetInteger(0, bearish_ob[i].name, OBJPROP_COLOR, color_of_bearish_ob);
 }

//+------------------------------------------------------------------+
void Eliminar_Objetos() //Function to delete objects
 {
  ObjectsDeleteAll(0, "ENTRY", -1, -1);
  for(int i = 0; i < ArraySize(pricetwo_eliminados_oba) ; i++)
    ObjectDelete(0, pricetwo_eliminados_oba[i]);
  for(int i = 0; i < ArraySize(pricetwo_eliminados_obb) ; i++)
    ObjectDelete(0, pricetwo_eliminados_obb[i]);
  for(int i = 0; i < ArraySize(bullish_ob) ; i++)
    ObjectDelete(0, bullish_ob[i].name);
  for(int i = 0; i < ArraySize(bearish_ob) ; i++)
    ObjectDelete(0, bearish_ob[i].name);

  ArrayFree(pricetwo_eliminados_oba);
  ArrayFree(pricetwo_eliminados_obb);
 }

//+------------------------------------------------------------------+
//|  Funciones para la creacion de objetos                           |
//+------------------------------------------------------------------+
void RectangleCreate(long chart_ID, string name, const int sub_window, datetime time1, double price1, datetime time2,
                     double price2, color clr, int width, bool fill, bool back, ENUM_LINE_STYLE style, bool select, string tooltip)
 {
  ResetLastError(); //we reset the last error
//verification and creation of the rectangle
  if(!ObjectCreate(chart_ID, name, OBJ_RECTANGLE, sub_window, time1, price1, time2, price2))
   {
    ob_logger.LogError(StringFormat("Failed to create rectangle: %s, last error description = %s", name, ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
   }
  ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, tooltip);
  ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
  ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
  ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
  ObjectSetInteger(chart_ID, name, OBJPROP_FILL, fill);
  ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, select);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, select);
 }

//+------------------------------------------------------------------+
bool TrendCreate(long            chart_ID,
                 string          name,
                 int             sub_window,
                 datetime        time1,
                 double          price1,
                 datetime        time2,
                 double          price2,
                 color           clr,
                 ENUM_LINE_STYLE style,
                 int             width,
                 bool            back,
                 bool            selection
                )
 {
  ResetLastError();
//--- We create the trend line according to the established coordinates
  if(!ObjectCreate(chart_ID, name, OBJ_TREND, sub_window, time1, price1, time2, price2))
   {
    ob_logger.LogError(StringFormat("Failed to create trend_line: %s, last error description = %s", name, ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
    return(false);
   }
  ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
  ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
  ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
  ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);

//---
  return(true);
 }

//+------------------------------------------------------------------+
bool TextCreate(long              chart_ID,
                string            name,
                int               sub_window,
                datetime                time,
                double                  price,
                string            text,
                string            font,
                int               font_size,
                color             clr,
                double            angle,
                ENUM_ANCHOR_POINT anchor,
                bool              back = false,
                bool              selection = false)


 {
  ResetLastError();
//--- we create the "Text" object
  if(!ObjectCreate(chart_ID, name, OBJ_TEXT, sub_window, time, price))
   {
    ob_logger.LogError(StringFormat("Failed to create text: %s, last error description = %s", name, ErrorDescription(GetLastError())), ORDER_BLOCK_IND_NAME);
    return(false);
   }
  ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
  ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
  ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
  ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
  ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
  ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
  ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
  return(true);
 }

//+------------------------------------------------------------------+
//| Transparencia                                                    |
//+------------------------------------------------------------------+
color ApplyTransparency(color fg, double alpha)
 {
// Clamp alpha between 0.0 and 1.0
  alpha = MathMax(0.0, MathMin(1.0, alpha));

// Get background color of the current chart
  long bg_long;
  if(!ChartGetInteger(0, CHART_COLOR_BACKGROUND, 0, bg_long))
    bg_long = clrWhite; // Fallback if it fails

  color bg = (color)bg_long;

// Decompose foreground color
  int r_fg = (fg >> 16) & 0xFF;
  int g_fg = (fg >> 8)  & 0xFF;
  int b_fg = fg & 0xFF;

// Decompose background color
  int r_bg = (bg >> 16) & 0xFF;
  int g_bg = (bg >> 8)  & 0xFF;
  int b_bg = bg & 0xFF;

// Blend each channel
  int r = (int)(r_fg * alpha + r_bg * (1.0 - alpha));
  int g = (int)(g_fg * alpha + g_bg * (1.0 - alpha));
  int b = (int)(b_fg * alpha + b_bg * (1.0 - alpha));

// Compose final color
  return (color)((r << 16) | (g << 8) | b);
 }
//+------------------------------------------------------------------+
