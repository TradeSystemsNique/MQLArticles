//+------------------------------------------------------------------+
//|                                                         Sort.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict

 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
void SortArrayDescendente(S* &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
  if(left >= right)
    return;

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
  SortArrayDescendente(array, left, j, mayor, params);
  SortArrayDescendente(array, i, right, mayor, params);
 }

//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
void SortArrayAscendente(S* &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
  if(left >= right)
    return;

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
  SortArrayAscendente(array, left, j, mayor, params);
  SortArrayAscendente(array, i, right, mayor, params);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
void SortArrayDescendente(S &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
  if(left >= right)
    return;

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
  SortArrayDescendente(array, left, j, mayor, params);
  SortArrayDescendente(array, i, right, mayor, params);
 }

//+------------------------------------------------------------------+
template <typename S, typename CompareFuncionMayor>
void SortArrayAscendente(S &array[], int left, int right, CompareFuncionMayor mayor, MqlParam &params[])
 {
  if(left >= right)
    return;

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
  SortArrayAscendente(array, left, j, mayor, params);
  SortArrayAscendente(array, i, right, mayor, params);
 }
//+------------------------------------------------------------------+
