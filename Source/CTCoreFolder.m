#import "CTCoreFolder.h"
#import "libetpan.h"
#import "CTCoreMessage.h"
#import "CTCoreAccount.h"
#import "MailCoreTypes.h"
	
@implementation CTCoreFolder
- (id)initWithPath:(NSString *)path inAccount:(CTCoreAccount *)account; {
	struct mailstorage *storage = (struct mailstorage *)[account storageStruct];
	self = [super init];
	if (self)
	{
		myPath = [path retain];
		connected = NO;
		myAccount = [account retain];
		myFolder = mailfolder_new(storage, (char *)[myPath cStringUsingEncoding:NSASCIIStringEncoding], NULL);	
		assert(myFolder != NULL);
	}
	return self;
}


- (void)dealloc {	
	if (connected)
		[self disconnect];
		
	mailfolder_free(myFolder);
	[myAccount release];
	[myPath release];
	[super dealloc];
}


- (void)connect {
	int err = MAIL_NO_ERROR;
	err =  mailfolder_connect(myFolder);
	if (err != MAIL_NO_ERROR) {
		connected = NO;
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
	mailfolder_disconnect(myFolder);
}


- (NSString *)name {
	//Get the last part of the path
	NSArray *pathParts = [myPath componentsSeparatedByString:@"."];
	return [pathParts objectAtIndex:[pathParts count]-1];
}


- (NSString *)path {
	return myPath;
}


- (void)setPath:(NSString *)path; {
	int err;
	const char *newPath = [path cStringUsingEncoding:NSASCIIStringEncoding];
	const char *oldPath = [myPath cStringUsingEncoding:NSASCIIStringEncoding];
	
	[self connect];	
	[self unsubscribe];
	err =  mailimap_rename([myAccount session], oldPath, newPath);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	else {
		[path retain];
		[myPath release];
		myPath = path;
		[self subscribe];
	}
}


- (void)create; {
	int err;
	const char *path = [myPath cStringUsingEncoding:NSASCIIStringEncoding];
	
	err =  mailimap_create([myAccount session], path);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	else {
		[self connect];
		[self subscribe];	
	}
}


- (void)delete; {
	int err;
	const char *path = [myPath cStringUsingEncoding:NSASCIIStringEncoding];
	
	[self connect];
	[self unsubscribe];
	err =  mailimap_delete([myAccount session], path);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}	
}


- (void)subscribe;
{
	int err;
	const char *path = [myPath cStringUsingEncoding:NSASCIIStringEncoding];
	
	[self connect];
	err =  mailimap_subscribe([myAccount session], path);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}	
}


- (void)unsubscribe;
{
	int err;
	const char *path = [myPath cStringUsingEncoding:NSASCIIStringEncoding];
	
	[self connect];
	err =  mailimap_unsubscribe([myAccount session], path);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}	
}


- (struct mailfolder *)folderStruct {
	return myFolder;
}


- (BOOL)isUIDValid:(NSString *)uid {
	uint32_t uidvalidity, check_uidvalidity;
	mailimap *imapSession;
	
	[self connect];
	imapSession = [self imapSession];
	if (imapSession->imap_selection_info != NULL) {
		uidvalidity = imapSession->imap_selection_info->sel_uidvalidity;
		check_uidvalidity = (uint32_t)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:0] doubleValue];
		return (uidvalidity == check_uidvalidity);
	}
	return NO;
}


- (void)check {
	[self connect];
	int err = mailfolder_check(myFolder);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
}


- (NSSet *)messageListFromUID:(NSString *)uid {
	struct mailmessage_list *msgList;
	struct mailmessage *msg;
	unsigned int len = 0, err = 0, uidnum = 0;
	NSString *newUID;
	NSMutableSet *messages = [NSMutableSet set];

	[self connect];
	if (uid == nil)
		uidnum = 0;
	else
		uidnum = (unsigned int)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:1] doubleValue];

	mailmessage_driver *driver = imap_message_driver;
	err = imap_get_messages_list([self imapSession], [self folderSession], driver, (uint32_t)uidnum+1, &msgList);
	if (err != MAIL_NO_ERROR) {
		if ( msgList != NULL )
			mailmessage_list_free(msgList);
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	
	len = carray_count(msgList->msg_tab);
	int i;
	for(i=0; i<len; i++) {
		msg = carray_get(msgList->msg_tab, i);
		newUID = [[NSString alloc] initWithCString:msg->msg_uid encoding:NSASCIIStringEncoding];
		[messages addObject:newUID];
		[newUID release];
	}
	if ( msgList != NULL )
		mailmessage_list_free(msgList);
	return messages;
}


- (NSSet *)messageObjectsFromIndex:(unsigned int)start toIndex:(unsigned int)end {
	struct mailmessage_list * env_list;
	int r;
	struct mailimap_fetch_att * fetch_att;
	struct mailimap_fetch_type * fetch_type;
	struct mailimap_set * set;
	clist * fetch_result;

	[self connect];
	set = mailimap_set_new_interval(start, end);
	if (set == NULL) 
		return nil;

	fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
	fetch_att = mailimap_fetch_att_new_uid();
	r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	if (r != MAILIMAP_NO_ERROR) {
		mailimap_fetch_att_free(fetch_att);
		return nil;
	}

	fetch_att = mailimap_fetch_att_new_rfc822_size();
	if (fetch_att == NULL) {
		mailimap_fetch_type_free(fetch_type);
		return nil;
	}

	r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	if (r != MAILIMAP_NO_ERROR) {
		mailimap_fetch_att_free(fetch_att);
		mailimap_fetch_type_free(fetch_type);
		return nil;
	}

	r = mailimap_uid_fetch([self imapSession], set, fetch_type, &fetch_result);
	if (r != MAIL_NO_ERROR) {
		if ( env_list != NULL )
			mailmessage_list_free(env_list);
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",r]
			        userInfo:nil];
		[exception raise];
	}

	mailimap_fetch_type_free(fetch_type);
	mailimap_set_free(set);

	if (r != MAILIMAP_NO_ERROR) 
		return nil; //Add exception

	env_list = NULL;
	r = uid_list_to_env_list(fetch_result, &env_list, [self folderSession], imap_message_driver);
	mailimap_fetch_list_free(fetch_result);

	
	r = mailfolder_get_envelopes_list(myFolder, env_list);
	if (r != MAIL_NO_ERROR) {
		if ( env_list != NULL )
			mailmessage_list_free(env_list);
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",r]
			        userInfo:nil];
		[exception raise];
	}
	
	int len = carray_count(env_list->msg_tab);
	int i;
	CTCoreMessage *msgObject;
	struct mailmessage *msg;
	NSMutableSet *messages = [NSMutableSet set];
	for(i=0; i<len; i++) {
		msg = carray_get(env_list->msg_tab, i);
		msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
		[messages addObject:msgObject];
		[msgObject release];
	}
	if ( env_list != NULL )
		carray_free(env_list->msg_tab); //I am only freeing the message array because the messages themselves are in use
	return messages;
}


- (NSSet *)messageObjectsFromUID:(NSString *)uid {
	struct mailmessage_list *msgList;
	struct mailmessage *msg;
	unsigned int len = 0, err = 0, uidnum = 0;
	NSMutableSet *messages = [NSMutableSet set];

	[self connect];
	if (uid == nil)
		uidnum = 0;
	else
		uidnum = (unsigned int)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:1] doubleValue];

	mailmessage_driver *driver = imap_message_driver;
	err = imap_get_messages_list([self imapSession], [self folderSession], driver, (uint32_t)uidnum+1, &msgList);
	if (err != MAIL_NO_ERROR) {
		if ( msgList != NULL )
			mailmessage_list_free(msgList);
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	
	err = mailfolder_get_envelopes_list(myFolder, msgList);
	if (err != MAIL_NO_ERROR) {
		if ( msgList != NULL )
			mailmessage_list_free(msgList);
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	
	len = carray_count(msgList->msg_tab);
	int i;
	CTCoreMessage *msgObject;
	for(i=0; i<len; i++) {
		msg = carray_get(msgList->msg_tab, i);
		msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
		[messages addObject:msgObject];
		[msgObject release];
	}
	if ( msgList != NULL )
		carray_free(msgList->msg_tab); //I am only freeing the message array because the messages themselves are in use
	return messages;	
}


- (CTCoreMessage *)messageWithUID:(NSString *)uid {
	int err;
	struct mailmessage *msgStruct;
	
	err = mailfolder_get_message_by_uid([self folderStruct], [uid cStringUsingEncoding:NSASCIIStringEncoding], &msgStruct);
	if (err == MAIL_ERROR_MSG_NOT_FOUND) {
		return nil;
	}
	else if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	err = mailmessage_fetch_envelope(msgStruct,&(msgStruct->msg_fields));
	if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];
	}
	return [[[CTCoreMessage alloc] initWithMessageStruct:msgStruct] autorelease];
}

/*	Why are flagsForMessage: and setFlags:forMessage: in CTCoreFolder instead of CTCoreMessage?
	One word: dependencies. These methods rely on CTCoreFolder and CTCoreMessage to do their work,
	if they were included with CTCoreMessage, than a reference to the folder would have to be kept at
	all times. So if you wanted to do something as simple as create an basic message to send via 
	SMTP, these flags methods wouldn't work because there wouldn't be a reference to a CTCoreFolder.
	By not including these methods, CTCoreMessage doesn't depend on CTCoreFolder anymore. CTCoreFolder
	already depends on CTCoreMessage so we aren't adding any dependencies here. */

- (NSDictionary *)flagsForMessage:(CTCoreMessage *)msg {
	struct mail_flags *flagStruct = NULL;
	uint32_t msgFlags;
	int err;
	NSMutableDictionary *theFlags = [NSMutableDictionary dictionaryWithObjectsAndKeys:CTFlagNotSet,CTFlagNew,
	CTFlagNotSet,CTFlagSeen,CTFlagNotSet,CTFlagFlagged,CTFlagNotSet,CTFlagDeleted,CTFlagNotSet,CTFlagAnswered,
	CTFlagNotSet,CTFlagForwarded,CTFlagNotSet,CTFlagCancelled,nil];
	
	err = mailmessage_get_flags([msg messageStruct], &flagStruct);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	if (flagStruct == NULL)
		return theFlags;
		
	msgFlags = flagStruct->fl_flags;
	if (msgFlags & MAIL_FLAG_NEW)
		[theFlags setObject:CTFlagSet forKey:CTFlagNew];
	if (msgFlags & MAIL_FLAG_SEEN)
		[theFlags setObject:CTFlagSet forKey:CTFlagSeen];
	if (msgFlags & MAIL_FLAG_FLAGGED)
		[theFlags setObject:CTFlagSet forKey:CTFlagFlagged];	
	if (msgFlags & MAIL_FLAG_DELETED)
		[theFlags setObject:CTFlagSet forKey:CTFlagDeleted];
	if (msgFlags & MAIL_FLAG_ANSWERED)
		[theFlags setObject:CTFlagSet forKey:CTFlagAnswered];
	if (msgFlags & MAIL_FLAG_FORWARDED)
		[theFlags setObject:CTFlagSet forKey:CTFlagForwarded];

	//TODO Implement advanced flags
	return theFlags;
}


- (void)setFlags:(NSDictionary *)flags forMessage:(CTCoreMessage *)msg {
	int err;
	uint32_t msgFlags = 0;
	
	if ([[flags objectForKey:CTFlagNew] isEqual:CTFlagSet])
		msgFlags = msgFlags | MAIL_FLAG_NEW;
	if ([[flags objectForKey:CTFlagSeen] isEqual:CTFlagSet])
		msgFlags = msgFlags | MAIL_FLAG_SEEN;
	if ([[flags objectForKey:CTFlagFlagged] isEqual:CTFlagSet])
		msgFlags = msgFlags | MAIL_FLAG_FLAGGED;
	if ([[flags objectForKey:CTFlagDeleted] isEqual:CTFlagSet])
		msgFlags = msgFlags | MAIL_FLAG_DELETED;
	if ([[flags objectForKey:CTFlagAnswered] isEqual:CTFlagSet])
		msgFlags = msgFlags | MAIL_FLAG_ANSWERED;
	if ([[flags objectForKey:CTFlagForwarded] isEqual:CTFlagSet])
		msgFlags = msgFlags | MAIL_FLAG_FORWARDED;
	
	[msg messageStruct]->msg_flags->fl_flags=msgFlags;
	err = mailmessage_check([msg messageStruct]);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	[self check];
}


- (void)expunge {
	int err;
	[self connect];
	err = mailfolder_expunge(myFolder);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
}


- (NSNumber *)unreadMessageCount {
	unsigned int unseenCount = 0;
	unsigned int junk;
	int err;
	
	[self connect];
	err =  mailfolder_status(myFolder, &junk, &junk, &unseenCount);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	return [NSNumber numberWithUnsignedInt:unseenCount];
}


- (NSNumber *)totalMessageCount {
	unsigned int totalCount = 0;
	unsigned int junk;
	int err;
			
	[self connect];			
	err =  mailfolder_status(myFolder, &totalCount, &junk, &junk);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	return [NSNumber numberWithUnsignedInt:totalCount];	
}


- (mailsession *)folderSession; {
	return myFolder->fld_session;
}


- (mailimap *)imapSession; {
	struct imap_cached_session_state_data * cached_data;
	struct imap_session_state_data * data;
	mailsession *session;
   
	session = [self folderSession];
	if (strcasecmp(session->sess_driver->sess_name, "imap-cached") == 0) {
    	cached_data = session->sess_data;
    	session = cached_data->imap_ancestor;
  	}

	data = session->sess_data;
	return data->imap_session;	
}


/* From Libetpan source */
int uid_list_to_env_list(clist * fetch_result, struct mailmessage_list ** result, 
						mailsession * session, mailmessage_driver * driver) {
	clistiter * cur;
	struct mailmessage_list * env_list;
	int r;
	int res;
	carray * tab;
	unsigned int i;
	mailmessage * msg;

	tab = carray_new(128);
	if (tab == NULL) {
		res = MAIL_ERROR_MEMORY;
		goto err;
	}

	for(cur = clist_begin(fetch_result); cur != NULL; cur = clist_next(cur)) {
		struct mailimap_msg_att * msg_att;
		clistiter * item_cur;
		uint32_t uid;
		size_t size;

		msg_att = clist_content(cur);

		uid = 0;
		size = 0;
		for(item_cur = clist_begin(msg_att->att_list); item_cur != NULL; item_cur = clist_next(item_cur)) {
			struct mailimap_msg_att_item * item;

			item = clist_content(item_cur);

			switch (item->att_type) {
				case MAILIMAP_MSG_ATT_ITEM_STATIC:
				switch (item->att_data.att_static->att_type) {
					case MAILIMAP_MSG_ATT_UID:
						uid = item->att_data.att_static->att_data.att_uid;
					break;

					case MAILIMAP_MSG_ATT_RFC822_SIZE:
						size = item->att_data.att_static->att_data.att_rfc822_size;
					break;
				}
				break;
			}
		}

		msg = mailmessage_new();
		if (msg == NULL) {
			res = MAIL_ERROR_MEMORY;
			goto free_list;
		}

		r = mailmessage_init(msg, session, driver, uid, size);
		if (r != MAIL_NO_ERROR) {
			res = r;
			goto free_msg;
		}

		r = carray_add(tab, msg, NULL);
		if (r < 0) {
			res = MAIL_ERROR_MEMORY;
			goto free_msg;
		}
	}

	env_list = mailmessage_list_new(tab);
	if (env_list == NULL) {
		res = MAIL_ERROR_MEMORY;
		goto free_list;
	}

	* result = env_list;

	return MAIL_NO_ERROR;

	free_msg:
		mailmessage_free(msg);
	free_list:
		for(i = 0 ; i < carray_count(tab) ; i++)
		mailmessage_free(carray_get(tab, i));
	err:
		return res;
}
@end
