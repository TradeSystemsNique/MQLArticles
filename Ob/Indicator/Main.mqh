#import "stdlib.ex5"
string ErrorDescription(int error_code);
#import

int    kBar, kStart=1667, kEnd=1670, kSeq=0;

#define fprint Print(__FUNCTION__," ",
#define fprintd Print(__FUNCTION__," ",StringSubstr((string)Pairs[0].time[LastBar],5,12)," "," ",

string DTS(double data,int Decimals)   {return(DoubleToString(data,Decimals));}

void Delete_Objects(string buffer)   {
   string name;
   for(int i=ObjectsTotal(0);i>=0;i--)      {
      name=ObjectName(0,i);
      if(StringLen(name) >= StringLen(buffer))  if(StringFind(name,buffer,0) >= 0) ObjectDelete(0,name);
   }
   GetLastError();
}

ushort ucomma=StringGetCharacter(",",0); 

string ErrorDescription(int error_code)  {
   string error_string;
   switch(error_code)     {
      //--- codes returned from trade server
      case 0:   error_string="no error";                                                   break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="trade server is busy";                                       break;
      case 5:   error_string="old version of the client terminal";                         break;
      case 6:   error_string="no connection with trade server";                            break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="too frequent requests";                                      break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="account disabled";                                           break;
      case 65:  error_string="invalid account";                                            break;
      case 128: error_string="trade timeout";                                              break;
      case 129: error_string="invalid price";                                              break;
      case 130: error_string="invalid stops";                                              break;
      case 131: error_string="invalid trade volume";                                       break;
      case 132: error_string="market is closed";                                           break;
      case 133: error_string="trade is disabled";                                          break;
      case 134: error_string="not enough money";                                           break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="long positions only allowed";                                break;
      case 141: error_string="too many requests";                                          break;
      case 145: error_string="modification denied because order is too close to market";   break;
      case 146: error_string="trade context is busy";                                      break;
      case 147: error_string="expirations are denied by broker";                           break;
      case 148: error_string="amount of open and pending orders has reached the limit";    break;
      case 149: error_string="hedging is prohibited";                                      break;
      case 150: error_string="prohibited by FIFO rules";                                   break;
      //--- mql4 errors
      case 4000: error_string="no error (never generated code)";                           break;
      case 4001: error_string="wrong function pointer";                                    break;
      case 4002: error_string="array index is out of range";                               break;
      case 4003: error_string="no memory for function call stack";                         break;
      case 4004: error_string="recursive stack overflow";                                  break;
      case 4005: error_string="not enough stack for parameter";                            break;
      case 4006: error_string="no memory for parameter string";                            break;
      case 4007: error_string="no memory for temp string";                                 break;
      case 4008: error_string="non-initialized string";                                    break;
      case 4009: error_string="non-initialized string in array";                           break;
      case 4010: error_string="no memory for array\' string";                              break;
      case 4011: error_string="too long string";                                           break;
      case 4012: error_string="remainder from zero divide";                                break;
      case 4013: error_string="zero divide";                                               break;
      case 4014: error_string="unknown command";                                           break;
      case 4015: error_string="wrong jump (never generated error)";                        break;
      case 4016: error_string="non-initialized array";                                     break;
      case 4017: error_string="dll calls are not allowed";                                 break;
      case 4018: error_string="cannot load library";                                       break;
      case 4019: error_string="cannot call function";                                      break;
      case 4020: error_string="expert function calls are not allowed";                     break;
      case 4021: error_string="not enough memory for temp string returned from function";  break;
      case 4022: error_string="system is busy (never generated error)";                    break;
      case 4023: error_string="dll-function call critical error";                          break;
      case 4024: error_string="internal error";                                            break;
      case 4025: error_string="out of memory";                                             break;
      case 4026: error_string="invalid pointer";                                           break;
      case 4027: error_string="too many formatters in the format function";                break;
      case 4028: error_string="parameters count is more than formatters count";            break;
      case 4029: error_string="invalid array";                                             break;
      case 4030: error_string="no reply from chart";                                       break;
      case 4050: error_string="invalid function parameters count";                         break;
      case 4051: error_string="invalid function parameter value";                          break;
      case 4052: error_string="string function internal error";                            break;
      case 4053: error_string="some array error";                                          break;
      case 4054: error_string="incorrect series array usage";                              break;
      case 4055: error_string="custom indicator error";                                    break;
      case 4056: error_string="arrays are incompatible";                                   break;
      case 4057: error_string="global variables processing error";                         break;
      case 4058: error_string="global variable not found";                                 break;
      case 4059: error_string="function is not allowed in Testing mode";                   break;
      case 4060: error_string="function is not confirmed";                                 break;
      case 4061: error_string="send mail error";                                           break;
      case 4062: error_string="string parameter expected";                                 break;
      case 4063: error_string="integer parameter expected";                                break;
      case 4064: error_string="double parameter expected";                                 break;
      case 4065: error_string="array as parameter expected";                               break;
      case 4066: error_string="requested history data is in update state";                 break;
      case 4067: error_string="internal trade error";                                      break;
      case 4068: error_string="resource not found";                                        break;
      case 4069: error_string="resource not supported";                                    break;
      case 4070: error_string="duplicate resource";                                        break;
      case 4071: error_string="cannot initialize custom indicator";                        break;
      case 4072: error_string="cannot load custom indicator";                              break;
      case 4073: error_string="no history data";                                           break;
      case 4074: error_string="not enough memory for history data";                        break;
      case 4075: error_string="not enough memory for indicator";                           break;
      case 4099: error_string="end of file";                                               break;
      case 4100: error_string="some file error";                                           break;
      case 4101: error_string="wrong file name";                                           break;
      case 4102: error_string="too many opened files";                                     break;
      case 4103: error_string="cannot open file";                                          break;
      case 4104: error_string="incompatible access to a file";                             break;
      case 4105: error_string="no order selected";                                         break;
      case 4106: error_string="unknown symbol";                                            break;
      case 4107: error_string="invalid price parameter for trade function";                break;
      case 4108: error_string="invalid ticket";                                            break;
      case 4109: error_string="trade is not allowed in the expert properties";             break;
      case 4110: error_string="longs are not allowed in the expert properties";            break;
      case 4111: error_string="shorts are not allowed in the expert properties";           break;
      case 4200: error_string="object already exists";                                     break;
      case 4201: error_string="unknown object property";                                   break;
      case 4202: error_string="object does not exist";                                     break;
      case 4203: error_string="unknown object type";                                       break;
      case 4204: error_string="no object name";                                            break;
      case 4205: error_string="object coordinates error";                                  break;
      case 4206: error_string="no specified subwindow";                                    break;
      case 4207: error_string="graphical object error";                                    break;
      case 4210: error_string="unknown chart property";                                    break;
      case 4211: error_string="chart not found";                                           break;
      case 4212: error_string="chart subwindow not found";                                 break;
      case 4213: error_string="chart indicator not found";                                 break;
      case 4220: error_string="symbol select error";                                       break;
      case 4250: error_string="notification error";                                        break;
      case 4251: error_string="notification parameter error";                              break;
      case 4252: error_string="notifications disabled";                                    break;
      case 4253: error_string="notification send too frequent";                            break;
      case 4260: error_string="ftp server is not specified";                               break;
      case 4261: error_string="ftp login is not specified";                                break;
      case 4262: error_string="ftp connect failed";                                        break;
      case 4263: error_string="ftp connect closed";                                        break;
      case 4264: error_string="ftp change path error";                                     break;
      case 4265: error_string="ftp file error";                                            break;
      case 4266: error_string="ftp error";                                                 break;
      case 5001: error_string="too many opened files";                                     break;
      case 5002: error_string="wrong file name";                                           break;
      case 5003: error_string="too long file name";                                        break;
      case 5004: error_string="cannot open file";                                          break;
      case 5005: error_string="text file buffer allocation error";                         break;
      case 5006: error_string="cannot delete file";                                        break;
      case 5007: error_string="invalid file handle (file closed or was not opened)";       break;
      case 5008: error_string="wrong file handle (handle index is out of handle table)";   break;
      case 5009: error_string="file must be opened with FILE_WRITE flag";                  break;
      case 5010: error_string="file must be opened with FILE_READ flag";                   break;
      case 5011: error_string="file must be opened with FILE_BIN flag";                    break;
      case 5012: error_string="file must be opened with FILE_TXT flag";                    break;
      case 5013: error_string="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: error_string="file must be opened with FILE_CSV flag";                    break;
      case 5015: error_string="file read error";                                           break;
      case 5016: error_string="file write error";                                          break;
      case 5017: error_string="string size must be specified for binary file";             break;
      case 5018: error_string="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: error_string="file is directory, not file";                               break;
      case 5020: error_string="file does not exist";                                       break;
      case 5021: error_string="file cannot be rewritten";                                  break;
      case 5022: error_string="wrong directory name";                                      break;
      case 5023: error_string="directory does not exist";                                  break;
      case 5024: error_string="specified file is not directory";                           break;
      case 5025: error_string="cannot delete directory";                                   break;
      case 5026: error_string="cannot clean directory";                                    break;
      case 5027: error_string="array resize error";                                        break;
      case 5028: error_string="string resize error";                                       break;
      case 5029: error_string="structure contains strings or dynamic arrays";              break;
      default:   error_string=StringFormat("unknown error[%d]\nCheck Error List in MQL Documentation",error_code);
     }
//---
   return(error_string);
}

string getUninitReasonText(int reasonCode)   { 
   string text=""; 
   switch(reasonCode)      { 
      case REASON_ACCOUNT:     text="Account was changed";break; 
      case REASON_CHARTCHANGE: text="Symbol or timeframe was changed";break; 
      case REASON_CHARTCLOSE:  text="Chart was closed";break; 
      case REASON_PARAMETERS:  text="Input-parameter was changed";break; 
      case REASON_RECOMPILE:   text="Program "+__FILE__+" was recompiled";break; 
      case REASON_REMOVE:      text="Program "+__FILE__+" was removed from chart";break; 
      case REASON_TEMPLATE:    text="New template was applied to chart";break; 
      default:                 text="Another reason"; 
     } 
   return text; 
  }
  
//+------------------------------------------------------------------+
//| Base Logging System with Flags                                   |
//+------------------------------------------------------------------+
#define FUNCION_ACTUAL __FUNCTION__ //Current function

//--- Log Flags
#define LOG_LEVEL_ERROR    1    // 0001 - Errors
#define LOG_LEVEL_WARNING  2    // 0010 - Warnings
#define LOG_LEVEL_INFO     4    // 0100 - General information
#define LOG_LEVEL_CAUTION  8    // 1000 - Precautions
#define LOG_ALL LOG_LEVEL_CAUTION|LOG_LEVEL_INFO|LOG_LEVEL_WARNING

//---
enum ENUM_VERBOSE_LOG_LEVEL
 {
  VERBOSE_LOG_LEVEL_ERROR_ONLY    = LOG_LEVEL_ERROR,             // Only Errors
  VERBOSE_LOG_LEVEL_WARNINGS      = LOG_LEVEL_WARNING,           // Warnings + Errors
  VERBOSE_LOG_LEVEL_INFO          = LOG_LEVEL_INFO,              // Info + Errors
  VERBOSE_LOG_LEVEL_CAUTION       = LOG_LEVEL_CAUTION,           // Caution + Errors
  VERBOSE_LOG_LEVEL_WARNINGS_INFO = LOG_LEVEL_WARNING | LOG_LEVEL_INFO,           // Warnings + Info + Errors
  VERBOSE_LOG_LEVEL_WARNINGS_CAUTION = LOG_LEVEL_WARNING | LOG_LEVEL_CAUTION,     // Warnings + Caution + Errors
  VERBOSE_LOG_LEVEL_INFO_CAUTION  = LOG_LEVEL_INFO | LOG_LEVEL_CAUTION,           // Info + Caution + Errors
  VERBOSE_LOG_LEVEL_ALL           = (LOG_LEVEL_WARNING | LOG_LEVEL_INFO | LOG_LEVEL_CAUTION)  // All: Warnings + Info + Caution + Errors
 };

#define WARNING_TEXT "WARNING"
#define CAUTION_TEXT "CAUTION"
#define INFO_TEXT "INFO"
#define ERROR_TEXT "ERROR"
#define CRITICAL_ERROR_TEXT "CRITICAL ERROR"
#define FATAL_ERROR_TEXT "FATAL ERROR"


//+------------------------------------------------------------------+
//| Base Logging Class with Flag System                              |
//+------------------------------------------------------------------+
class CLogger
 {
private:
  uint8_t            m_log_flags;         
  uint8_t            m_last_flags;

  bool               m_warning_enable;
  bool               m_caution_enable;
  bool               m_info_enable;

  // Main logging method with flags
  inline void        RemoveFlag(uint8_t flags) { this.m_log_flags &= ~flags; }
  void               Update();

public:
                     CLogger() { m_log_flags = LOG_LEVEL_ERROR; this.m_last_flags = LOG_LEVEL_ERROR; Update(); }


  //--- General function
  static inline void FastLog(const string& function, const string& class_info, const string& message);


  // Methods to check if a flag is active
  inline bool        IsWarningLogEnabled() const { return m_warning_enable; }
  inline bool        IsInfoLogEnabled() const { return m_info_enable; }
  inline bool        IsCautionLogEnabled() const { return m_caution_enable; }

  // Getters
  inline uint8_t     LogFlags() const { return m_log_flags; }
  inline bool        IsLogEnabled(uint8_t flag) const { return (m_log_flags & flag) != 0; }

  // Main configuration using flags
  inline void        AddLogFlags(const uint8_t flags);
  void               RemoveLogFlags(const uint8_t flags);
  inline void        ResetLastStateFlags() { this.m_log_flags = m_last_flags; }

  // Utilitarian methods
  void               EnableAllLogs();
  void               DisableAllLogs();
  
  // Flag-specific methods (easier to use)
  static inline void LogError(const string &message, const string &function);
  inline void        LogWarning(const string &message, const string &function)  const;
  inline void        LogInfo(const string &message, const string &function)  const;
  inline void        LogCaution(const string &message, const string &function)  const;
  static inline void LogFatalError(const string &message, const string &function);
  static inline void LogCriticalError(const string &message, const string &function);
 };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLogger::DisableAllLogs()
 {
  m_log_flags = LOG_LEVEL_ERROR;
  Update();
 }

//+------------------------------------------------------------------+
void CLogger::EnableAllLogs(void)
 {
  m_log_flags |= LOG_ALL;
  Update();
 }

//+------------------------------------------------------------------+
inline void CLogger::AddLogFlags(const uint8_t flags)
 {
  this.m_last_flags = m_log_flags;
  m_log_flags |= flags;
  Update();
 }

//+------------------------------------------------------------------+
void CLogger::RemoveLogFlags(const uint8_t flags)
 {
  this.m_last_flags = m_log_flags;
  uint8_t safe_flags = flags & ~LOG_LEVEL_ERROR;
  RemoveFlag(safe_flags);
  m_log_flags |= LOG_LEVEL_ERROR;
  Update();
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static inline void CLogger::FastLog(const string& function, const string& class_info, const string& message)
 {
  Print("[", class_info, "] ", function, " | ", message);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static inline void CLogger::LogError(const string &message, const string& function)
 {
  FastLog(function, ERROR_TEXT, message);
 }
//+------------------------------------------------------------------+
static inline void CLogger::LogCriticalError(const string &message, const string& function)
 {
  FastLog(function, CRITICAL_ERROR_TEXT, message);
 }
//+------------------------------------------------------------------+
static inline void CLogger::LogFatalError(const string &message, const string& function)
 {
  FastLog(function, FATAL_ERROR_TEXT, message);
 }
//+------------------------------------------------------------------+
inline void CLogger::LogWarning(const string &message, const string& function) const
 {
  if(m_warning_enable)
    FastLog(function, WARNING_TEXT, message);
 }
//+------------------------------------------------------------------+
inline void CLogger::LogInfo(const string &message, const string& function) const
 {
  if(m_info_enable)
    FastLog(function, INFO_TEXT, message);
 }
//+------------------------------------------------------------------+
inline void CLogger::LogCaution(const string &message, const string& function) const
 {
  if(m_caution_enable)
    FastLog(function, CAUTION_TEXT, message);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLogger::Update(void)
 {
  this.m_warning_enable = (m_log_flags & LOG_LEVEL_WARNING) != 0;
  this.m_info_enable = (m_log_flags & LOG_LEVEL_INFO) != 0;
  this.m_caution_enable = (m_log_flags & LOG_LEVEL_CAUTION) != 0;
 }

CLogger ob_logger;
