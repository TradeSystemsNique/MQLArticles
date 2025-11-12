//+------------------------------------------------------------------+
//|                                              IndicatorsBases.mqh |
//|                                             Copyright 2025, Leo. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Leo."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict

#ifndef MQLARTICLES_INDICATORSCTS_INDICATORSBASES_MQH
#define MQLARTICLES_INDICATORSCTS_INDICATORSBASES_MQH


//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include "..\\..\\MQLArticles\\Utils\\Funciones Array.mqh"

//+------------------------------------------------------------------+
//| Indicator Buffer                                                 |
//+------------------------------------------------------------------+
struct IndBuffer
 {
  double             data[];
 };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiIndicatorSimple : public CLoggerBase
 {
protected:
  ENUM_TIMEFRAMES    m_timeframe;
  string             m_symbol;
  int                m_handle;
  string             m_name;
  IndBuffer          m_data[];
  bool               m_realese;

public:
                     CiIndicatorSimple();
                    ~CiIndicatorSimple();

  //---
  bool               Create(int handle, bool series, int buffers_num);

  //---
  inline void        CleanData();

  //---
  inline int         Handle()        const { return m_handle;    }
  inline string      Name()          const { return m_name;      }
  inline ENUM_TIMEFRAMES Timeframe() const { return m_timeframe; }
  inline string      Simbolo()       const { return m_symbol;    }
  inline bool        Realese()       const { return m_realese;   }

  //---
  inline void        Realese(bool realese) { m_realese = realese; }
  inline void        SetAsSeries(bool series);

  //---
  inline void        GetData(double &out[], int buffer_num)    const  { ArrayCopy(out, m_data[buffer_num].data);   }
  inline int         Size(int buffer_num)                      const  { return ArraySize(m_data[buffer_num].data); }
  inline double GetValue(int index, int buffer_num = 0)        const  { return m_data[buffer_num].data[index];     }

  //---
  inline bool        CopyData(int start, int count, int buffer_num);
 };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiIndicatorSimple::CiIndicatorSimple()
  : m_timeframe(WRONG_VALUE), m_symbol(NULL), m_handle(INVALID_HANDLE), m_realese(true)
 {
  ArrayResize(m_data, 0);
 }

//+------------------------------------------------------------------+
CiIndicatorSimple::~CiIndicatorSimple()
 {
  if(m_realese && m_handle != INVALID_HANDLE)
   {
    IndicatorRelease(m_handle);
   }
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
inline bool CiIndicatorSimple::CopyData(int start, int count, int buffer_num)
 {
  ResetLastError();
  if(!CopyBuffer(m_handle, buffer_num, start, count, m_data[buffer_num].data))
   {
    LogError(StringFormat("Error copying data from %d, total %d", start, count), FUNCION_ACTUAL);
    return false;
   }
  return true;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiIndicatorSimple::Create(int handle, bool series, int buffers_num)
 {
  this.m_handle = handle;
  if(this.m_handle == INVALID_HANDLE)
   {
    LogError(StringFormat("Error creating indicator %s, invalid handle", m_name), FUNCION_ACTUAL);
    return false;
   }

//---
  ArrayResize(m_data, buffers_num);

//---
  if(series)
    SetAsSeries(true);
  return true;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
inline void CiIndicatorSimple::CleanData(void)
 {
  ArrayFree(m_data);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
inline void CiIndicatorSimple::SetAsSeries(bool series)
 {
  for(int i = 0; i < ArraySize(m_data); i++)
    ArraySetAsSeries(m_data[i].data, series);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiRsi : public CiIndicatorSimple
 {
public:
                     CiRsi() { m_name = "Rsi"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, int period, ENUM_APPLIED_PRICE applied, bool series, bool hide);
 };
//+------------------------------------------------------------------+
bool CiRsi::Create(ENUM_TIMEFRAMES timeframe, string symbol, int period, ENUM_APPLIED_PRICE applied, bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iRSI(symbol, timeframe, period, applied);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
  return CiIndicatorSimple::Create(m_handle, series, 1);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiMa : public CiIndicatorSimple
 {
public:
                     CiMa(void) { m_name = "Ema"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, int period, ENUM_APPLIED_PRICE applied, int ma_shift, ENUM_MA_METHOD ma_method
                            , bool series, bool hide);
 };

//+------------------------------------------------------------------+
bool CiMa::Create(ENUM_TIMEFRAMES timeframe, string symbol, int period, ENUM_APPLIED_PRICE applied, int ma_shift, ENUM_MA_METHOD ma_method
                  , bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iMA(symbol, timeframe, period, ma_shift, ma_method, applied);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
  return CiIndicatorSimple::Create(m_handle, series, 1);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiCci : public CiIndicatorSimple
 {
public:
                     CiCci(void) { m_name = "CCI"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, int period, ENUM_APPLIED_PRICE applied, bool series, bool hide);

 };

//+------------------------------------------------------------------+
bool CiCci::Create(ENUM_TIMEFRAMES timeframe, string symbol, int period, ENUM_APPLIED_PRICE applied, bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iCCI(symbol, timeframe, period, applied);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
  return CiIndicatorSimple::Create(m_handle, series, 1);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiStocastic : public CiIndicatorSimple
 {
public:
                     CiStocastic(void) { m_name = "Stocastico"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, int kperiod, int dperiod, int slowing, ENUM_MA_METHOD ma_method, ENUM_STO_PRICE stop_price
                            , bool series, bool hide);

 };

//+------------------------------------------------------------------+
bool CiStocastic::Create(ENUM_TIMEFRAMES timeframe, string symbol, int kperiod, int dperiod, int slowing, ENUM_MA_METHOD ma_method, ENUM_STO_PRICE stop_price
                         , bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iStochastic(symbol, timeframe, kperiod, dperiod, slowing, ma_method, stop_price);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
  return CiIndicatorSimple::Create(m_handle, series, 2);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiVIDyA : public CiIndicatorSimple
 {
public:
                     CiVIDyA(void) { m_name = "VIDyA"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, int cmo_period, int ema_period, int ma_shift, ENUM_APPLIED_PRICE applied, bool series, bool hide);
 };

//+------------------------------------------------------------------+
bool CiVIDyA::Create(ENUM_TIMEFRAMES timeframe, string symbol, int cmo_period, int ema_period, int ma_shift, ENUM_APPLIED_PRICE applied, bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iVIDyA(symbol, timeframe, cmo_period, ema_period, ma_shift, applied);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
  return CiIndicatorSimple::Create(m_handle, series, 1);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiBands : public CiIndicatorSimple
 {
public:
                     CiBands(void) { m_name = "Bollinger Bands"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, int bands_period, int bands_shift, double deviation,
                            ENUM_APPLIED_PRICE applied_price, bool series, bool hide);
 };

//+------------------------------------------------------------------+
bool CiBands::Create(ENUM_TIMEFRAMES timeframe, string symbol, int bands_period, int bands_shift, double deviation,
                     ENUM_APPLIED_PRICE applied_price, bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iBands(symbol, timeframe, bands_period, bands_shift, deviation, applied_price);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
  return CiIndicatorSimple::Create(m_handle, series, 3);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#resource "Super trend cts.ex5"



//---
class CiSuperTrend : public CiIndicatorSimple
 {
public:
                     CiSuperTrend(void) { m_name = "SuperTrend" ; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, bool series, bool hide, int cci_period = 50);
 };

//+------------------------------------------------------------------+
bool CiSuperTrend::Create(ENUM_TIMEFRAMES timeframe, string symbol, bool series, bool hide, int cci_period = 50)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iCustom(symbol, timeframe, "::Super trend cts.ex5", cci_period);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
// Buffer[0] = price of super trend
// Buffer[1] = direction  [2 = bullish trend | 1 = berish trend]

  return CiIndicatorSimple::Create(m_handle, series, 2);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#resource "VWAP.ex5"

//---
enum VWAP_Period
 {
  VWAP_Diario = 0,
  VWAP_Semanal,
  VWAP_Mensual
 };

//+------------------------------------------------------------------+
class CiVwapChange : public CiIndicatorSimple
 {
public:
                     CiVwapChange(void) { m_name = "VwapChange"; }
  bool               Create(ENUM_TIMEFRAMES timeframe, string symbol, VWAP_Period period, ENUM_APPLIED_PRICE applied, bool series, bool hide);
 };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiVwapChange::Create(ENUM_TIMEFRAMES timeframe, string symbol, VWAP_Period period, ENUM_APPLIED_PRICE applied, bool series, bool hide)
 {
//---
  if(hide)
    TesterHideIndicators(true);

  m_handle = iCustom(symbol, timeframe, "::VWAP.ex5", period, applied);

  if(hide)
    TesterHideIndicators(false);

//---
  m_timeframe = timeframe;
  m_symbol = symbol;
// Buffer[0] = buy
// Buffer[1] = sell
  return CiIndicatorSimple::Create(m_handle, series, 2);
 }
#endif // MQLARTICLES_INDICATORSCTS_INDICATORSBASES_MQH
//+------------------------------------------------------------------+
