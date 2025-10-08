# MQLArticles 
Una colección completa de implementaciones en MQL5 para gestión de riesgo y posiciones en trading algorítmico.                                                                                                                                          
Este repositorio contiene el código fuente de artículos publicados en MQL5.com por nique_372.


## Contenido del Repositorio

### 📁 Estructura del Proyecto

| Carpeta | Archivos | Descripción |
|---------|----------|-------------|
| **Examples** | - Get_Lot_By_Risk_Per_Trade_and_SL.mq5<br>- Get_Sl_by_risk_per_operation_and_lot.mq5<br>- Risk_Management_Panel.mq5 | Ejemplos prácticos del uso de la librería de gestión de riesgo (RM). |
| **OrderBlock** | - Main.mqh<br>- Order Block EA MT5.mq5<br>- OrderBlockIndPart2.mq5 | Contiene el indicador y el bot de Order Blocks usados como ejemplos en la serie de artículos de gestión de riesgo, breakeven y parciales. |
| **PosManagement** | - Breakeven.mqh<br>- Partials.mqh | Librerías específicas para la gestión de posiciones: breakeven y cierre parcial. |
| **RM** | - AccountStatus.mqh<br>- LossProfit.mqh<br>- LoteSizeCalc.mqh<br>- Modificators.mqh<br>- OcoOrder.mqh<br>- OrdersGestor.mqh<br>- RiskManagement.mqh<br>- RiskManagementBases.mqh<br>- RM_Defines.mqh<br>- RM_Functions.mqh | Todos los módulos que conforman la librería de gestión de riesgo RM. |
| **Utils** | - FA\   <br>&nbsp;&nbsp;&nbsp;&nbsp;- Atr.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- AtrCts.ex5<br>&nbsp;&nbsp;&nbsp;&nbsp;- BarControler.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- ClasesBases.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- Events.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- FuncionesBases.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- Managers.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- SimpleLogger.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- Sort.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- StringToArray.mqh<br>- CustomOptimization.mqh<br>- Fibonacci.mqh<br>- File.mqh<br>- Funciones Array.mqh<br>- Objectos 2D.mqh<br>- RandomSimple.mqh | Librería de utilidades para la creación de librerías, EAs e indicadores. Incluye funciones para trabajar con arrays, tiempo, conversiones, strings, matemáticas simples, además de clases para manejo de patrones de velas, ATR optimizado, validación de suspensión del PC, entre otros. |
| **Sets** | - Article_Partials\   <br>&nbsp;&nbsp;&nbsp;&nbsp;ARTICLE_PARTIAL_SET_TEST_2_OB_WITHOUT_PARTIALS.set<br>&nbsp;&nbsp;&nbsp;&nbsp;- ARTICLE_PARTIAL_SET_OB_TEST_2_WITH_PARTIALS.set<br>&nbsp;&nbsp;&nbsp;&nbsp;- ARTICLE_PARTIAL_SET_TEST_1_WITH_PARTIALS.set<br>&nbsp;&nbsp;&nbsp;&nbsp;- ARTICLE_PARTIAL_SET_TEST_1_WITHOUT_PARTIALS.set | Carpeta que contiene los sets utilizados en el test 1y 2. |


## Serie de Artículos Implementados
### Gestión de Riesgo (Risk Management)

| Parte | Tema Principal | Enlace al Artículo |
|-------|----------------|-------------------|
| **Parte 1** | Fundamentos de la gestion de riesgo | [Ver Artículo](https://www.mql5.com/es/articles/16820) |
| **Parte 2** | Cálculo del lote | [Ver Artículo](https://www.mql5.com/es/articles/16985) |
| **Parte 3** | Construccion de la clase base | [Ver Artículo](https://www.mql5.com/es/articles/17249) |
| **Parte 4** | Finalizacion de las funciones clave de la clase CRiskManagement| [Ver Artículo](https://www.mql5.com/es/articles/17508) |
| **Parte 5** | Integracion de la gestion de riesgo en un EA (order block) | [Ver Artículo](https://www.mql5.com/es/articles/17640) |

> **Actualización Importante**: La librería RiskManagement ha sido completamente renovada desde la última publicación (parte 5).

### Gestión de Posiciones - Breakeven

| Parte | Enfoque | Enlace al Artículo |
|-------|---------|-------------------|
| **Parte 1** | Clase base y breakevent por puntos fijos | [Ver Artículo](https://www.mql5.com/es/articles/17957) |
| **Parte 2** | Breakeven por atr y rrr | [Ver Artículo](https://www.mql5.com/es/articles/18111) |

### Order Block Indicator

| Parte | Enfoque | Enlace al Artículo |
|-------|---------|-------------------|
| **Parte 1** | Implementacion inicial de los order blocks en un indicador | [Ver Artículo](https://www.mql5.com/es/articles/15899) |
| **Parte 2** | Implementacion de señales en el indicador de order blocks | [Ver Artículo](https://www.mql5.com/es/articles/16268) |



### Metodos de Instalación
- Clonar el repositorio git en shared proyects a travez del cmd.
- Escribirme por privado en MQL5 chats (user: nique_372), para que te agrege como colaborador con tu nickname de MQL5 (solo lectura) haciendo que te aparecera el repositorio en tu carpeta sharedproyects automaticamente.
- Fork al repositorio.    





