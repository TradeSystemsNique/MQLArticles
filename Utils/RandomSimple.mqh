//+------------------------------------------------------------------+
//|                                                 RandomSimple.mqh |
//|                                  Copyright 2025, Niquel Mendoza. |
//|                     https://www.mql5.com/es/users/nique_372/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Niquel Mendoza."
#property link      "https://www.mql5.com/es/users/nique_372/news"
#property strict


//#define RANDOM_SIMPLE_STRICT

//+------------------------------------------------------------------+
//| Clase para la generacion de valores random                       |
//+------------------------------------------------------------------+
class CRandomSimple
 {
private:
  uint               m_seed;

public:
                     CRandomSimple() : m_seed(0) {  }

  //--- Seed
  inline uint        Seed() const { return m_seed; }
  inline void        Seed(const uint new_value) { MathSrand((m_seed = new_value)); } // operator = devuleve new_value

  //--- Randoms
  //- Random Short
  short              RandomShort(short start, short step, short stop);
  short              RandomShort(short start, short stop);

  //- Random long
  long               RandomLong(long start, long step, long stop);
  long               RandomLong(long start, long stop);

  //- Random int
  int                RandomInt(int start, int step, int stop);
  int                RandomInt(int start, int stop);

  //- Random double
  double             RandomDouble(double start, double step, double stop);
  double             RandomDouble(double start, double stop);

  //- Random float
  float              RandomFloat(float start, float step, float stop);
  float              RandomFloat(float start, float stop);

  //- Random bool
  bool               RandomBool();

  //--- Select
  template <typename T>
  T                  RandomSelect(const T &arr[]);

  template <typename T>
  void               RandomSelectMultiple(const T &arr[], T &out[], short elements_to_select);

  template <typename T>
  void               RandomSelectMultiple(const T &arr[], T &out[], int elements_to_select);
 };

//+------------------------------------------------------------------+
//| RandomLong con step                                              |
//+------------------------------------------------------------------+
long CRandomSimple::RandomLong(long start, long step, long stop)
 {
#ifdef RANDOM_SIMPLE_STRICT
  if(step <= 0 || start >= stop)
    return 0;
#endif

  long range = (stop - start) / step;
  long rand_val = 0;
  if(range <= 32767)
   {
    rand_val = MathRand() % (range + 1);
   }
  else
   {
    rand_val = ((long)MathRand() << 16) | MathRand();
    rand_val = rand_val % (range + 1);
   }

  return start + rand_val * step;
 }
//+------------------------------------------------------------------+
//| RandomLong sin step                                              |
//+------------------------------------------------------------------+
long CRandomSimple::RandomLong(long start, long stop)
 {
  return RandomLong(start, 1, stop);
 }
//+------------------------------------------------------------------+
//| RandomInt con step                                               |
//+------------------------------------------------------------------+
int CRandomSimple::RandomInt(int start, int step, int stop)
 {
#ifdef RANDOM_SIMPLE_STRICT
  if(step <= 0 || start >= stop)
    return 0;
#endif

  int range = (stop - start) / step;
  int rand_val = 0;
  if(range <= 32767)
   {
    rand_val = MathRand() % (range + 1);
   }
  else
   {
    rand_val = (MathRand() << 15) | MathRand();
    rand_val = rand_val % (range + 1);
   }

  return start + rand_val * step;
 }
//+------------------------------------------------------------------+
//| RandonInt sin step                                               |
//+------------------------------------------------------------------+
int CRandomSimple::RandomInt(int start, int stop)
 {
  return RandomInt(start, 1, stop);
 }

//+------------------------------------------------------------------+
//| RandomShort con step                                             |
//+------------------------------------------------------------------+
short CRandomSimple::RandomShort(short start, short step, short stop)
 {
#ifdef RANDOM_SIMPLE_STRICT
  if(step <= 0 || start >= stop)
    return 0;
#endif
  short range = (stop - start) / step;
  short rand_val = (short)MathRand() % (range + 1); // No hya problema con el cast mathrand solo retorna de 0 - SHORT_MAX
  return start + rand_val * step;
 }
//+------------------------------------------------------------------+
//| RandomShort sin step                                             |
//+------------------------------------------------------------------+
short CRandomSimple::RandomShort(short start, short stop)
 {
  return RandomShort(start, 1, stop);
 }

//+------------------------------------------------------------------+
//| RandomDouble con step                                            |
//+------------------------------------------------------------------+
double CRandomSimple::RandomDouble(double start, double step, double stop)
 {
#ifdef RANDOM_SIMPLE_STRICT
  if(step <= 0.00000000000001 || start >= stop)
    return 0.00;
#endif

  int steps = (int)MathAbs((stop - start) / step);
  int rand_val = 0;
  if(steps <= 32767)
   {
    rand_val = MathRand() % (steps + 1);
   }
  else
   {
    rand_val = (MathRand() << 15) | MathRand();
    rand_val = rand_val % (steps + 1);
   }

  return start + rand_val * step;
 }
//+------------------------------------------------------------------+
//| RandomDouble sin step                                            |
//+------------------------------------------------------------------+
double CRandomSimple::RandomDouble(double start, double stop)
 {
  double rand_val = (double)MathRand() / 32767.0;
  return start + rand_val * (stop - start);
 }
//+------------------------------------------------------------------+
//| RandomFloat con step                                             |
//+------------------------------------------------------------------+
float CRandomSimple::RandomFloat(float start, float step, float stop)
 {
#ifdef RANDOM_SIMPLE_STRICT
  if(step <= 0.00000f || start >= stop)
    return 0.0f;
#endif

  int steps = (int)MathAbs((stop - start) / step);
  int rand_val = 0;
  if(steps <= 32767)
   {
    rand_val = MathRand() % (steps + 1);
   }
  else
   {
    rand_val = (MathRand() << 15) | MathRand();
    rand_val = rand_val % (steps + 1);
   }

  return (float)(start + rand_val * step);
 }
//+------------------------------------------------------------------+
//| RandomFloat sin step                                             |
//+------------------------------------------------------------------+
float CRandomSimple::RandomFloat(float start, float stop)
 {
  float rand_val = (float)MathRand() / 32767.0f;
  return start + rand_val * (stop - start);
 }
//+------------------------------------------------------------------+
//| RandomSelect - selecciona elemento aleatorio del array           |
//+------------------------------------------------------------------+
template <typename T>
T CRandomSimple::RandomSelect(const T &arr[])
 {
  T empty_value;
  const int size = ArraySize(arr);
  return size == 0 ? empty_value : arr[RandomInt(0, size - 1)];
 }
//+--------------------------------------------------------------------------+
//| RandomSelect - selecciona varios elementos aleatorios del array          |
//+--------------------------------------------------------------------------+
template <typename T>
void CRandomSimple::RandomSelectMultiple(const T &arr[], T &out[], short elements_to_select)
 {
  const int size = ArraySize(arr);
  if(size < 1)
    return;

//---
#ifdef RANDOM_SIMPLE_STRICT
  if(elements_to_select > size)
    elements_to_select = size;

  if(elements_to_select < 1)
    return;
#endif

//---
  ArrayResize(out, elements_to_select);

//---
  int indices[];
  ArrayResize(indices, size);

//---
  for(int i = 0; i < size; i++)
    indices[i] = i;

//---
  for(int i = 0; i < elements_to_select; i++)
   {
    //---
    const int randIdx = MathRand() % (size - i);

    //---
    out[i] = arr[indices[randIdx]];

    //---
    const int temp = indices[randIdx];
    indices[randIdx] = indices[size - i - 1];
    indices[size - i - 1] = temp;
   }
 }

//+--------------------------------------------------------------------------+
//| RandomSelect - selecciona varios elementos aleatorios del array          |
//+--------------------------------------------------------------------------+
template <typename T>
void CRandomSimple::RandomSelectMultiple(const T &arr[], T &out[], int elements_to_select)
 {
  const int size = ArraySize(arr);
  if(size < 1)
    return;

//---
#ifdef RANDOM_SIMPLE_STRICT
  if(elements_to_select > size)
    elements_to_select = size;

  if(elements_to_select < 1)
    return;
#endif

//---
  ArrayResize(out, elements_to_select);

//---
  int indices[];
  ArrayResize(indices, size);

//---
  for(int i = 0; i < size; i++)
    indices[i] = i;

//---
  for(int i = 0; i < elements_to_select; i++)
   {
    //---
    const int randIdx = RandomInt(0, size - i - 1);

    //---
    out[i] = arr[indices[randIdx]];

    //---
    const int temp = indices[randIdx];
    indices[randIdx] = indices[size - i - 1];
    indices[size - i - 1] = temp;
   }
 }

//+------------------------------------------------------------------+
//| RandomBool                                                       |
//+------------------------------------------------------------------+
bool CRandomSimple::RandomBool()
 {
  return (MathRand() % 2) == 1;
 }
//+------------------------------------------------------------------+
