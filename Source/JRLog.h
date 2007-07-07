/*******************************************************************************
	JRLog.h
		Copyright (c) 2006-2007 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>

	***************************************************************************/

#import <Foundation/Foundation.h>

//	What you need to remember: Debug > Info > Warn > Error > Fatal.

typedef enum {
	JRLogLevel_UNSET,
    JRLogLevel_Debug,
    JRLogLevel_Info,
    JRLogLevel_Warn,
    JRLogLevel_Error,
    JRLogLevel_Fatal,
	JRLogLevel_Off,
} JRLogLevel;

@interface NSObject (JRLogAdditions)
+ (JRLogLevel)classJRLogLevel;
+ (void)setClassJRLogLevel:(JRLogLevel)level_;

+ (JRLogLevel)defaultJRLogLevel;
+ (void)setDefaultJRLogLevel:(JRLogLevel)level_;
@end

BOOL IsJRLogLevelActive(id self_, JRLogLevel level_);
void JRLog(id self_, JRLogLevel level_, unsigned line_, const char *file_, const char *function_, NSString *format_, ...);

#define JRLOG_CONDITIONALLY(sender,LEVEL,format,...) \
	if(IsJRLogLevelActive(sender,LEVEL)){JRLog(sender,LEVEL,__LINE__,__FILE__,__PRETTY_FUNCTION__,(format),##__VA_ARGS__);}

#if JRLogOverrideNSLog
id self;
#define NSLog	JRLogInfo
#endif

//
//	Scary macros!
//	The 1st #if is a filter, which you can read "IF any of the symbols are defined, THEN don't log for that level, ELSE log for that level."
//

#if defined(JRLOGLEVEL_OFF) || defined(JRLOGLEVEL_FATAL) || defined(JRLOGLEVEL_ERROR) || defined(JRLOGLEVEL_WARN) || defined(JRLOGLEVEL_INFO)
	#define JRLogDebug(format,...)
#else
	#define JRLogDebug(format,...)		JRLOG_CONDITIONALLY(self, JRLogLevel_Debug, format, ##__VA_ARGS__)
#endif

#if defined(JRLOGLEVEL_OFF) || defined(JRLOGLEVEL_FATAL) || defined(JRLOGLEVEL_ERROR) || defined(JRLOGLEVEL_WARN)
	#define JRLogInfo(format,...)
#else
	#define JRLogInfo(format,...)		JRLOG_CONDITIONALLY(self, JRLogLevel_Info, format, ##__VA_ARGS__)
#endif

#if defined(JRLOGLEVEL_OFF) || defined(JRLOGLEVEL_FATAL) || defined(JRLOGLEVEL_ERROR)
	#define JRLogWarn(format,...)
#else
	#define JRLogWarn(format,...)		JRLOG_CONDITIONALLY(self, JRLogLevel_Warn, format, ##__VA_ARGS__)
#endif

#if defined(JRLOGLEVEL_OFF) || defined(JRLOGLEVEL_FATAL)
	#define JRLogError(format,...)
#else
	#define JRLogError(format,...)		JRLOG_CONDITIONALLY(self, JRLogLevel_Error, format, ##__VA_ARGS__)
#endif

#if defined(JRLOGLEVEL_OFF)
	#define JRLogFatal(format,...)
#else
	#define JRLogFatal(format,...)		JRLOG_CONDITIONALLY(self, JRLogLevel_Fatal, format, ##__VA_ARGS__)
#endif
