# MQLArticles 
A comprehensive collection of MQL5 implementations for risk management and position management in algorithmic trading.
This repository contains the source code from articles published on MQL5.com by nique_372.


## Repository Contents

### Project Structure

| Folder | Files | Description |
|---------|-------|-------------|
| **Examples** | - Get_Lot_By_Risk_Per_Trade_and_SL.mq5<br>- Get_Sl_by_risk_per_operation_and_lot.mq5<br>- Risk_Management_Panel.mq5 | Practical examples of using the Risk Management (RM) library. |
| **IndicatorsCts** | - IndicatorsBases.mqh | Wrapper library for implementing simple indicators using classes. |
| **Ob** | - **Bots/**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Art19682/**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Ea.mq5<br><br>- **Indicator/**<br>&nbsp;&nbsp;&nbsp;&nbsp;- Main.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- OrderBlockIndPart2.mq5 | Includes the Order Blocks indicator, as well as the Expert Advisors used as examples in other articles published by the author (nique_372). |
| **PosManagement** | - **ConditionalPartial/**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  **Base/**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  - Base.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Defines.mqh<br>- Breakeven.mqh<br>- Partials.mqh | Contains libraries for position management:<br>- Breakeven<br>- Partial closure<br>- Conditional partial closure. |
| **RM** | - AccountStatus.mqh<br>- LossProfit.mqh<br>- LoteSizeCalc.mqh<br>- Modificators.mqh<br>- OcoOrder.mqh<br>- OrdersGestor.mqh<br>- RiskManagement.mqh<br>- RiskManagementBases.mqh<br>- RM_Defines.mqh<br>- RM_Functions.mqh | All modules that make up the RM risk management library. |
| **Utils** | - **FA/**<br>&nbsp;&nbsp;&nbsp;&nbsp;- Atr.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- AtrCts.ex5<br>&nbsp;&nbsp;&nbsp;&nbsp;- BarControler.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- ClasesBases.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- Events.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- FuncionesBases.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- Managers.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- SimpleLogger.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- Sort.mqh<br>&nbsp;&nbsp;&nbsp;&nbsp;- StringToArray.mqh<br><br>- CustomOptimization.mqh<br>- Fibonacci.mqh<br>- File.mqh<br>- Funciones Array.mqh<br>- GraphicObjects.mqh<br>- RandomSimple.mqh | Utility library for creating libraries, EAs, and indicators. Includes functions for working with arrays, time, conversions, strings, simple mathematics, and classes for candlestick pattern handling, optimized ATR, PC suspension validation, among others. |
| **Sets** | - **Article_19682/**<br>&nbsp;&nbsp;&nbsp;ARTICLE_PARTIAL_SET_TEST_2_OB_WITHOUT_PARTIALS.set<br>&nbsp;&nbsp;&nbsp;&nbsp;- ARTICLE_PARTIAL_SET_OB_TEST_2_WITH_PARTIALS.set<br>&nbsp;&nbsp;&nbsp;&nbsp;- ARTICLE_PARTIAL_SET_TEST_1_WITH_PARTIALS.set<br>&nbsp;&nbsp;&nbsp;&nbsp;- ARTICLE_PARTIAL_SET_TEST_1_WITHOUT_PARTIALS.set | Sets used in other articles published by the author (nique_372). |


## Implemented Article Series

### Risk Management

| Part | Main Topic | Article Link |
|-------|----------------|-------------------|
| **Part 1** | Risk management fundamentals | [[EN]](https://www.mql5.com/en/articles/16820) |
| **Part 2** | Lot size calculation | [[ES]](https://www.mql5.com/es/articles/16985) |
| **Part 3** | Base class construction | [[ES]](https://www.mql5.com/es/articles/17249) |
| **Part 4** | Completing key functions of the CRiskManagement class | [[ES]](https://www.mql5.com/es/articles/17508) |
| **Part 5** | Integrating risk management into an EA (Order Block) | [[ES]](https://www.mql5.com/es/articles/17640) |

> **Important Update**: The RiskManagement library has been completely renovated since the last publication (part 5).


### Position Management - Breakeven

| Part | Focus | Article Link |
|-------|---------|-------------------|
| **Part 1** | Base class and breakeven by fixed points | [[ES]](https://www.mql5.com/es/articles/17957) |
| **Part 2** | Breakeven by ATR and RRR | [[ES]](https://www.mql5.com/es/articles/18111) |


### Position Management - Partial Closes
| Focus | Article Link |
|-------|--------------------|
| Implementation of partial closes in MQL5 | [[ES]](https://www.mql5.com/es/articles/19682) |


### Order Block Indicator

| Part | Focus | Article Link |
|-------|---------|-------------------|
| **Part 1** | Initial implementation of Order Blocks in an indicator | [[EN]](https://www.mql5.com/en/articles/15899) |
| **Part 2** | Signal implementation in the Order Block indicator | [[EN]](https://www.mql5.com/en/articles/16268) |


## Installation Methods
- Clone the git repository into shared projects via cmd.
- Contact me privately on MQL5 chats (user: nique_372) to be added as a collaborator with your MQL5 nickname (read-only access), which will make the repository automatically appear in your sharedprojects folder.
- Fork the repository.