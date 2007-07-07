#import "libetpan.h"

/*!
	@abstract Enables logging of all streams, data is output to standard out.
*/
void MailCoreEnableLogging();

void IfFalse_RaiseException(bool value, NSString *exceptionName, NSString *exceptionDesc);
void IfTrue_RaiseException(bool value, NSString *exceptionName, NSString *exceptionDesc);
void RaiseException(NSString *exceptionName, NSString *exceptionDesc);