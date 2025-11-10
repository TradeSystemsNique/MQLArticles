//+------------------------------------------------------------------+
//|                                           CustomOptimization.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict

#ifndef MQLARTICLES_UTILS_CUSTOMOPTIMIZATION_MQH
#define MQLARTICLES_UTILS_CUSTOMOPTIMIZATION_MQH

#include "Funciones Array.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
typedef double (*FCustomOptimizerResult)();

//---
enum ENUM_SIMPLE_CUSTOM_CRITERIA
 {
  CTS_CRITERIA_OP_ESPERANZA_MATEMATICA = 0,
  CTS_CRITERIA_OP_MIN_DD_AND_MAX_BALANCE
 };

//---
class CCustomCriteria //clase para implementar un criterio custom de otpimaicion en el probador, ADEVERTENCIA: todas las funciones son de maximizacion
 {
private:
  FCustomOptimizerResult f_ptr;


public:
                     CCustomCriteria(void);

  //---
  void               Set(FCustomOptimizerResult funcion_rest) { this.f_ptr = funcion_rest; }
  void               Set(ENUM_SIMPLE_CUSTOM_CRITERIA type_op);

  //---
  inline double      OnTesterEvent() const { return this.f_ptr(); }
 };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCustomCriteria::CCustomCriteria(void)
  : f_ptr(NULL)
 {

 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCustomCriteria::Set(ENUM_SIMPLE_CUSTOM_CRITERIA type_op)
 {
  const static FCustomOptimizerResult types_valid[2] =
   {
    CCustomCriteria_FuncionEsperanzaMatematica,
    CCustomCriteria_FuncionMinDdAndMaxBalance
   };

  this.f_ptr = types_valid[type_op];
 }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CCustomCriteria_FuncionEsperanzaMatematica()
 {
  double trades = TesterStatistics(STAT_TRADES);

  if(trades <= 0)
    return 0.0;

//---
  double procentaje_accierto = TesterStatistics(STAT_PROFIT_TRADES) / trades;
  double percentage_fallo = TesterStatistics(STAT_LOSS_TRADES) / trades;

//---
  double total_profits = TesterStatistics(STAT_PROFIT_TRADES);
  double avg_profit = total_profits > 0.00 ? TesterStatistics(STAT_GROSS_PROFIT) /  total_profits : 0.00;

//---
  double total_losses =  TesterStatistics(STAT_LOSS_TRADES);
  double avg_loss = total_losses > 0.00 ? fabs(TesterStatistics(STAT_GROSS_LOSS)) / total_losses : 0.00;

  return (procentaje_accierto * avg_profit) - (percentage_fallo * avg_loss);
 }

//+------------------------------------------------------------------+
double CCustomCriteria_FuncionMinDdAndMaxBalance()
 {
  double gross;
  if((gross = TesterStatistics(STAT_GROSS_PROFIT)) <  TesterStatistics(STAT_GROSS_LOSS))
    return 0.00 ;//Si hay mas peridas qeu gannacias entonces retorna 0, bot no es rentalbe

  double dd =  TesterStatistics(STAT_BALANCEDD_PERCENT);

  if(dd > 30.00) //d + 50%, demasiado
    return 0.00;

  return gross / dd;
 }
//+------------------------------------------------------------------+
#endif // MQLARTICLES_UTILS_CUSTOMOPTIMIZATION_MQH