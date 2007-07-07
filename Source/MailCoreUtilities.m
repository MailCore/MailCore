#import "MailCoreUtilities.h"
#import "JRLog.h"

/* direction is 1 for send, 0 for receive, -1 when it does not apply */
void mailcore_logger(int direction, const char * str, size_t size) {
	char *str2 = malloc(size+1);
	strncpy(str2,str,size);
	str2[size] = 0;
	id self = nil; // Work around for using JRLogInfo in a C function
	if (direction == 1) {
		JRLogInfo(@"Client: %s\n", str2);
	}
	else if (direction == 0) {
		JRLogInfo(@"Server: %s\n", str2);
	}
	else {
		JRLogInfo(@"%s\n", str2);
	}
	free(str2);
}


void MailCoreEnableLogging() {
	mailstream_debug = 1;
	mailstream_logger = mailcore_logger;
}


void IfFalse_RaiseException(bool value, NSString *exceptionName, NSString *exceptionDesc) {
	if (!value)
		RaiseException(exceptionName, exceptionDesc);
}


void IfTrue_RaiseException(bool value, NSString *exceptionName, NSString *exceptionDesc) {
	if (value)
		RaiseException(exceptionName, exceptionDesc);
}


void RaiseException(NSString *exceptionName, NSString *exceptionDesc) {
	NSException *exception = [NSException
		        exceptionWithName:exceptionName
		        reason:exceptionDesc
		        userInfo:nil];
	[exception raise];
}