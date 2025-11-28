//+------------------------------------------------------------------+
//|                                                         Sort.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict

#ifndef MQLARTICLES_UTILS_FA_SORT_MQH
#define MQLARTICLES_UTILS_FA_SORT_MQH


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSimpleSort
 {
public:
                     CSimpleSort(void) {}
                    ~CSimpleSort(void) {}

  //--- Pointers
  //- Descendente
  template <typename S, typename CompareFuncionMayor>
  static void        SortDescendente(S* &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[]);

  template <typename S, typename CompareFuncionMayor>
  static void        SortDescendente(S* &array[], int left, int right, CompareFuncionMayor mayor);

  //- Asecendente
  template <typename S, typename CompareFuncionMayor>
  static void        SortAscendente(S* &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[]);

  template <typename S, typename CompareFuncionMayor>
  static void        SortAscendente(S* &array[], int left, int right, CompareFuncionMayor mayor);


  //--- Reference
  //- Descendente
  // Con Compare y Params
  template <typename S, typename CompareFuncionMayor>
  static void              SortDescendente(S &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[]);
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortDescendente(S &array[], int total, CompareFuncionMayor mayor, MqlParam &params[]) { SortDescendente(array, 0, (total - 1), mayor, params); }
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortDescendente(S &array[], CompareFuncionMayor mayor, MqlParam &params[]) { SortDescendente(array, 0, (ArraySize(array) - 1), mayor, params); }

  // Con compare
  template <typename S, typename CompareFuncionMayor>
  static void              SortDescendente(S &array[], int left, int right, CompareFuncionMayor mayor);
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortDescendente(S &array[], int total, CompareFuncionMayor mayor) { SortDescendente(array, 0, (total - 1), mayor); }
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortDescendente(S &array[], CompareFuncionMayor mayor) { SortDescendente(array, 0, (ArraySize(array) - 1), mayor); }

  // Sin compare
  template <typename S>
  static void              SortDescendente(S &array[], int left, int right);
  template <typename S>
  static __forceinline void SortDescendente(S &array[], int total) { SortDescendente(array, 0, total - 1); }
  template <typename S>
  static __forceinline void SortDescendente(S &array[]) { SortDescendente(array, 0, ArraySize(array) - 1); }

  //- Ascendente
  // Con Compare y Params
  template <typename S, typename CompareFuncionMayor>
  static void              SortAscendente(S &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[]);
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortAscendente(S &array[], int total, CompareFuncionMayor mayor, MqlParam &params[]) { SortAscendente(array, 0, (total - 1), mayor, params); }
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortAscendente(S &array[], CompareFuncionMayor mayor, MqlParam &params[]) { SortAscendente(array, 0, (ArraySize(array) - 1), mayor, params); }

  // Con compare
  template <typename S, typename CompareFuncionMayor>
  static void              SortAscendente(S &array[], int left, int right, CompareFuncionMayor mayor);
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortAscendente(S &array[], int total, CompareFuncionMayor mayor) { SortAscendente(array, 0, (total - 1), mayor); }
  template <typename S, typename CompareFuncionMayor>
  static __forceinline void SortAscendente(S &array[], CompareFuncionMayor mayor) { SortAscendente(array, 0, (ArraySize(array) - 1), mayor); }

  // Sin compare
  template <typename S>
  static void              SortAscendente(S &array[], int left, int right);
  template <typename S>
  static __forceinline void SortAscendente(S &array[], int total) { SortAscendente(array, 0, (total - 1)); }
  template <typename S>
  static __forceinline void SortAscendente(S &array[]) { SortAscendente(array, 0, (ArraySize(array) - 1)); }
 };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortDescendente(S* &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S* pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(params, array[i], pivotValue)) // array[i] > es mayor pivot
      i++;
    while(mayor(params, pivotValue, array[j]))
      j--;
    if(i <= j)
     {
      S* temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortDescendente(array, left, j, mayor, params);
  SortDescendente(array, i, right, mayor, params);
 }

//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortDescendente(S* &array[], int left, int right, CompareFuncionMayor mayor)
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S* pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(array[i], pivotValue)) // array[i] > es mayor pivot
      i++;
    while(mayor(pivotValue, array[j]))
      j--;
    if(i <= j)
     {
      S* temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortDescendente(array, left, j, mayor);
  SortDescendente(array, i, right, mayor);
 }




//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortAscendente(S *&array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S* pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(params, pivotValue, array[i]))
      i++;
    while(mayor(params, array[j], pivotValue))
      j--;
    if(i <= j)
     {
      S* temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortAscendente(array, left, j, mayor, params);
  SortAscendente(array, i, right, mayor, params);
 }


//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortAscendente(S *&array[], int left, int right, CompareFuncionMayor mayor)
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S* pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(pivotValue, array[i]))
      i++;
    while(mayor(array[j], pivotValue))
      j--;
    if(i <= j)
     {
      S* temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortAscendente(array, left, j, mayor);
  SortAscendente(array, i, right, mayor);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortDescendente(S &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(params, array[i], pivotValue)) // array[i] > es mayor pivot
      i++;
    while(mayor(params, pivotValue, array[j]))
      j--;
    if(i <= j)
     {
      S temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortDescendente(array, left, j, mayor, params);
  SortDescendente(array, i, right, mayor, params);
 }

//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortDescendente(S &array[], int left, int right, CompareFuncionMayor mayor)
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(array[i], pivotValue)) // array[i] > es mayor pivot
      i++;
    while(mayor(pivotValue, array[j]))
      j--;
    if(i <= j)
     {
      S temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortDescendente(array, left, j, mayor);
  SortDescendente(array, i, right, mayor);
 }

//+------------------------------------------------------------------+
template <typename S>
static void CSimpleSort::SortDescendente(S &array[], int left, int right)
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(array[i] > pivotValue) // array[i] > es mayor pivot
      i++;
    while(pivotValue > array[j])
      j--;
    if(i <= j)
     {
      S temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortDescendente(array, left, j);
  SortDescendente(array, i, right);
 }





//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortAscendente(S &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(params, pivotValue, array[i]))
      i++;
    while(mayor(params, array[j], pivotValue))
      j--;
    if(i <= j)
     {
      S temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortAscendente(array, left, j, mayor, params);
  SortAscendente(array, i, right, mayor, params);
 }

//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
static void CSimpleSort::SortAscendente(S &array[], int left, int right, CompareFuncionMayor mayor)
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(mayor(pivotValue, array[i]))
      i++;
    while(mayor(array[j], pivotValue))
      j--;
    if(i <= j)
     {
      S temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortAscendente(array, left, j, mayor);
  SortAscendente(array, i, right, mayor);
 }

//+------------------------------------------------------------------+
template <typename S>
static void CSimpleSort::SortAscendente(S &array[], int left, int right)
 {
//---
  if(left >= right)
    return;

//---
  const int pivotIndex = (left + right) >> 1;
  const S pivotValue = array[pivotIndex];
  int i = left, j = right;
  while(i <= j)
   {
    while(pivotValue > array[i])
      i++;
    while(array[j] > pivotValue)
      j--;
    if(i <= j)
     {
      S temp = array[i];
      array[i] = array[j];
      array[j] = temp;
      i++;
      j--;
     }
   }

//---
  SortAscendente(array, left, j);
  SortAscendente(array, i, right);
 }



//+------------------------------------------------------------------+
#endif // MQLARTICLES_UTILS_FA_SORT_MQH
