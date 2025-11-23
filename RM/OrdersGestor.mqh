//+------------------------------------------------------------------+
//|                                                 OrdersGestor.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict


#ifndef MQLARTICLES_RM_ORDERGESTOR_MQH
#define MQLARTICLES_RM_ORDERGESTOR_MQH

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "RM_Functions.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define CORDER_GESTOR_RESERVE_ARR 5
// #define CACCOUNT_STATUS_ACTIVE_ON_ORDER_DELETE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COrderGestor : public CAccountGestor
 {
private:
  int                total_ordenes;
  ulong              ordenes[];
  ulong              ea_magic;


public:
                     COrderGestor(void) : total_ordenes(0), ea_magic(0) { ArrayResize(ordenes, 0, CORDER_GESTOR_RESERVE_ARR); }
  //---
  void               Initialize(ulong _ea_magic);

  //--- Add
  bool               Add(ulong order_ticket);

  //--- Getters
  inline int         OrdenesTotales() const { return total_ordenes; }

  //---
  void               OnOrderDelete(const ROrder& order) override;
  void               OnOpenClosePosition(const ROnOpenClosePosition &pos) override { }
 };

//+------------------------------------------------------------------+
void COrderGestor::Initialize(ulong _ea_magic)
 {
  this.ea_magic = _ea_magic;
 }

//+------------------------------------------------------------------+
void COrderGestor::OnOrderDelete(const ROrder &order) override
 {
  if(order.order_magic != ea_magic)
    return;

//---
  int pos = -1;

//---
  for(int i = 0; i < total_ordenes; i++)
   {
    if(ordenes[i] == order.order_ticket)
     {
      pos = i;
      break;
     }
   }

//---
  if(pos == -1)
    return;

//---
  total_ordenes--;
  ordenes[pos] = ordenes[total_ordenes];

//---
  ArrayResize(ordenes, total_ordenes, CORDER_GESTOR_RESERVE_ARR);
 }

//+------------------------------------------------------------------+
bool COrderGestor::Add(ulong order_ticket)
 {
  if(order_ticket == INVALID_TICKET)
    return false;

  ArrayResize(ordenes, total_ordenes + 1, CORDER_GESTOR_RESERVE_ARR);
  ordenes[total_ordenes] = order_ticket;
  total_ordenes++;
  return true;
 }
#endif // MQLARTICLES_RM_ORDERGESTOR_MQH
//+------------------------------------------------------------------+
