#import "CTCoreAccount.h"
#import "CTCoreFolder.h"
#import "MailCoreTypes.h"

@interface CTCoreAccount (Private)
@end


@implementation CTCoreAccount
- (id)init {
	self = [super init];
	if (self) {
		connected = NO;
		myStorage = mailstorage_new(NULL);
		assert(myStorage != NULL);	
	}
	return self;
}


- (void)dealloc {
	mailstorage_free(myStorage);
	[super dealloc]; 
}


- (BOOL)isConnected {
	return connected;
}


- (void)connectToServer:(NSString *)server port:(int)port 
		connectionType:(int)conType authType:(int)authType
		login:(NSString *)login password:(NSString *)password {
	int err = 0;
	int imap_cached = 0;

	err = imap_mailstorage_init(myStorage, 
						(char *)[server cStringUsingEncoding:NSASCIIStringEncoding],
						(uint16_t)port, NULL, conType, authType,
						(char *)[login cStringUsingEncoding:NSASCIIStringEncoding],
						(char *)[password cStringUsingEncoding:NSASCIIStringEncoding],
						imap_cached, NULL);
	
	if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
		        exceptionWithName:CTMemoryError
		        reason:CTMemoryErrorDesc
		        userInfo:nil];
		[exception raise];
	}
						
	err = mailstorage_connect(myStorage);
	if (err == MAIL_ERROR_LOGIN) {
		NSException *exception = [NSException
		        exceptionWithName:CTLoginError
		        reason:CTLoginErrorDesc
		        userInfo:nil];
		[exception raise];
	}
	else if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
		        exceptionWithName:CTUnknownError
		        reason:[NSString stringWithFormat:@"Error number: %d",err]
		        userInfo:nil];
		[exception raise];
	}
	else	
		connected = YES;
}


- (void)disconnect {
	connected = NO;
	mailstorage_disconnect(myStorage);
}

- (CTCoreFolder *)folderWithPath:(NSString *)path {
	CTCoreFolder *folder = [[CTCoreFolder alloc] initWithPath:path inAccount:self];
	return [folder autorelease];
}


- (mailimap *)session {
	struct imap_cached_session_state_data * cached_data;
	struct imap_session_state_data * data;
	mailsession *session;
   
	session = myStorage->sto_session;
	if (strcasecmp(session->sess_driver->sess_name, "imap-cached") == 0) 
	{
    	cached_data = session->sess_data;
    	session = cached_data->imap_ancestor;
  	}

	data = session->sess_data;
	return data->imap_session;
}


- (struct mailstorage *)storageStruct {
	return myStorage;
}


- (NSSet *)subscribedFolders {
	struct mailimap_mailbox_list * mailboxStruct;
	clist *subscribedList;
	clistiter *cur;
	
	NSString *mailboxNameObject;
	char *mailboxName;
	int err;
	
	NSMutableSet *subscribedFolders = [NSMutableSet set];	
	
	//Fill the subscribed folder array
	err = mailimap_lsub([self session], "", "*", &subscribedList);
	if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	else if (clist_isempty(subscribedList)) {
		NSException *exception = [NSException
			        exceptionWithName:CTNoSubscribedFolders
			        reason:CTNoSubscribedFoldersDesc
			        userInfo:nil];
		[exception raise];
	}
	for(cur = clist_begin(subscribedList); cur != NULL; cur = cur->next) {
		mailboxStruct = cur->data;
		mailboxName = mailboxStruct->mb_name;
		mailboxNameObject = [NSString stringWithCString:mailboxName encoding:NSASCIIStringEncoding];
		[subscribedFolders addObject:mailboxNameObject];
	}
	mailimap_list_result_free(subscribedList);
	return subscribedFolders;
}

- (NSSet *)allFolders {
	struct mailimap_mailbox_list * mailboxStruct;
	clist *allList;
	clistiter *cur;
	
	NSString *mailboxNameObject;
	char *mailboxName;
	int err;
	
	NSMutableSet *allFolders = [NSMutableSet set];

	//Now, fill the all folders array
	//TODO Fix this so it doesn't use *
	err = mailimap_list([self session], "", "*", &allList);		
	if (err != MAIL_NO_ERROR)
	{
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	else if (clist_isempty(allList))
	{
		NSException *exception = [NSException
			        exceptionWithName:CTNoFolders
			        reason:CTNoFoldersDesc
			        userInfo:nil];
		[exception raise];
	}
	for(cur = clist_begin(allList); cur != NULL; cur = cur->next)
	{
		mailboxStruct = cur->data;
		mailboxName = mailboxStruct->mb_name;
		mailboxNameObject = [NSString stringWithCString:mailboxName encoding:NSASCIIStringEncoding];
		[allFolders addObject:mailboxNameObject];
	}
	mailimap_list_result_free(allList);
	return allFolders;
}
@end
