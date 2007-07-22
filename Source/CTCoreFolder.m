#import "CTCoreFolder.h"
#import "libetpan.h"
#import "CTCoreMessage.h"
#import "CTCoreAccount.h"
#import "MailCoreTypes.h"
#import "CTBareMessage.h"

@interface CTCoreFolder (Private)
@end
	
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
	uidvalidity = [self uidValidity];
	check_uidvalidity = (uint32_t)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:0] doubleValue];
	return (uidvalidity == check_uidvalidity);
}

- (NSUInteger)uidValidity {
	[self connect];
	mailimap *imapSession;
	imapSession = [self imapSession];
	if (imapSession->imap_selection_info != NULL) {
		return imapSession->imap_selection_info->sel_uidvalidity;
	}
	return 0;
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
		uidnum = (unsigned int)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:1] unsignedIntegerValue];

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

- (NSUInteger)sequenceNumberForUID:(NSString *)uid {
	//TODO check UID validity
	//TODO factor out this duplicate code
	
	int r;
	struct mailimap_fetch_att * fetch_att;
	struct mailimap_fetch_type * fetch_type;
	struct mailimap_set * set;
	clist * fetch_result;
	//TODO factor this out
	NSUInteger uidnum = (unsigned int)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:1] doubleValue];

	[self connect];
	set = mailimap_set_new_single(uidnum);
	if (set == NULL) 
		return 0;

	fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
	fetch_att = mailimap_fetch_att_new_uid();
	r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	if (r != MAILIMAP_NO_ERROR) {
		mailimap_fetch_att_free(fetch_att);
		return 0;
	}

	r = mailimap_uid_fetch([self imapSession], set, fetch_type, &fetch_result);
	if (r != MAIL_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",r]
			        userInfo:nil];
		[exception raise];
	}

	mailimap_fetch_type_free(fetch_type);
	mailimap_set_free(set);

	if (r != MAILIMAP_NO_ERROR) 
		return 0; //Add exception
	NSUInteger sequenceNumber = 0;	
	if (!clist_isempty(fetch_result)) {
		struct mailimap_msg_att *msg_att = (struct mailimap_msg_att *)clist_nth_data(fetch_result, 0);
		sequenceNumber = msg_att->att_number;
	}
	mailimap_fetch_list_free(fetch_result);	
	return sequenceNumber;
}

- (NSSet *)messageListWithFetchAttributes:(NSArray *)attributes {
	int r;
	struct mailimap_fetch_att * fetch_att;
	struct mailimap_fetch_type * fetch_type;
	struct mailimap_set * set;
	clist * fetch_result;

	[self connect];
	set = mailimap_set_new_interval(1, 0);
	if (set == NULL) 
		return nil;

	fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
	fetch_att = mailimap_fetch_att_new_uid();
	r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	if (r != MAILIMAP_NO_ERROR) {
		mailimap_fetch_att_free(fetch_att);
		return nil;
	}

	fetch_att = mailimap_fetch_att_new_flags();
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

	r = mailimap_fetch([self imapSession], set, fetch_type, &fetch_result);
	if (r != MAIL_NO_ERROR) {
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

	NSMutableSet *messages = [NSMutableSet set];
	NSUInteger uidValidity = [self uidValidity];
	clistiter *iter;
	for(iter = clist_begin(fetch_result); iter != NULL; iter = clist_next(iter)) {
		CTBareMessage *msg = [[CTBareMessage alloc] init];
		
		struct mailimap_msg_att *msg_att = clist_content(iter);
		clistiter * item_cur;
		uint32_t uid;
		struct mail_flags *flags;

		uid = 0;
		for(item_cur = clist_begin(msg_att->att_list); item_cur != NULL; 
			item_cur = clist_next(item_cur)) {
			struct mailimap_msg_att_item * item;

			NSString *str;
			item = clist_content(item_cur);
			switch (item->att_type) {
				case MAILIMAP_MSG_ATT_ITEM_STATIC:
				switch (item->att_data.att_static->att_type) {
					case MAILIMAP_MSG_ATT_UID:
					str = [[NSString alloc] initWithFormat:@"%d-%d", uidValidity,
										item->att_data.att_static->att_data.att_uid];
					msg.uid = str;
					[str release];
					break;
				}
				break;
				case MAILIMAP_MSG_ATT_ITEM_DYNAMIC:
				r = imap_flags_to_flags(item->att_data.att_dyn, &flags);
			 	if (r == MAIL_NO_ERROR) {
					msg.flags = flags->fl_flags;
			  	}
				break;
			}
		}
		[messages addObject:msg];
		[msg release];
  	}
	mailimap_fetch_list_free(fetch_result);	
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

	r = mailimap_fetch([self imapSession], set, fetch_type, &fetch_result);
	if (r != MAIL_NO_ERROR) {
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
	clistiter *fetchResultIter = clist_begin(fetch_result);
	NSMutableSet *messages = [NSMutableSet set];
	for(i=0; i<len; i++) {
		msg = carray_get(env_list->msg_tab, i);
		msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
		struct mailimap_msg_att *msg_att = (struct mailimap_msg_att *)clist_content(fetchResultIter);
		[msgObject setSequenceNumber:msg_att->att_number];
		[messages addObject:msgObject];
		[msgObject release];
		fetchResultIter = clist_next(fetchResultIter);
	}
	if ( env_list != NULL ) {
		//I am only freeing the message array because the messages themselves are in use
		carray_free(env_list->msg_tab); 
		free(env_list);
	}
	mailimap_fetch_list_free(fetch_result);	
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
	if ( msgList != NULL ) {
		//I am only freeing the message array because the messages themselves are in use
		carray_free(msgList->msg_tab); 
		free(msgList);
	}
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
	
	//TODO Fix me, i'm missing alot of things that aren't being downloaded, 
	// I just hacked this in here for the mean time
	err = mailmessage_get_flags(msgStruct, &(msgStruct->msg_flags));
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

- (unsigned int)flagsForMessage:(CTCoreMessage *)msg {
	int err;
	struct mail_flags *flagStruct;
	err = mailmessage_get_flags([msg messageStruct], &flagStruct);
	if (err != MAILIMAP_NO_ERROR) {
		NSException *exception = [NSException
			        exceptionWithName:CTUnknownError
			        reason:[NSString stringWithFormat:@"Error number: %d",err]
			        userInfo:nil];
		[exception raise];	
	}
	return flagStruct->fl_flags;
}


- (void)setFlags:(unsigned int)flags forMessage:(CTCoreMessage *)msg {
	int err;

	[msg messageStruct]->msg_flags->fl_flags=flags;
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


- (NSUInteger)unreadMessageCount {
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
	return unseenCount;
}


- (NSUInteger)totalMessageCount {
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
	return totalCount;
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

int imap_flags_to_flags(struct mailimap_msg_att_dynamic * att_dyn,
			       struct mail_flags ** result)
{
  struct mail_flags * flags;
  clist * flag_list;
  clistiter * cur;

  flags = mail_flags_new_empty();
  if (flags == NULL)
    goto err;
  flags->fl_flags = 0;

  flag_list = att_dyn->att_list;
  if (flag_list != NULL) {
    for(cur = clist_begin(flag_list) ; cur != NULL ;
        cur = clist_next(cur)) {
      struct mailimap_flag_fetch * flag_fetch;

      flag_fetch = clist_content(cur);
      if (flag_fetch->fl_type == MAILIMAP_FLAG_FETCH_RECENT)
	flags->fl_flags |= MAIL_FLAG_NEW;
      else {
	char * keyword;
	int r;

	switch (flag_fetch->fl_flag->fl_type) {
	case MAILIMAP_FLAG_ANSWERED:
	  flags->fl_flags |= MAIL_FLAG_ANSWERED;
	  break;
	case MAILIMAP_FLAG_FLAGGED:
	  flags->fl_flags |= MAIL_FLAG_FLAGGED;
	  break;
	case MAILIMAP_FLAG_DELETED:
	  flags->fl_flags |= MAIL_FLAG_DELETED;
	  break;
	case MAILIMAP_FLAG_SEEN:
	  flags->fl_flags |= MAIL_FLAG_SEEN;
	  break;
	case MAILIMAP_FLAG_DRAFT:
	  keyword = strdup("Draft");
	  if (keyword == NULL)
	    goto free;
	  r = clist_append(flags->fl_extension, keyword);
	  if (r < 0) {
	    free(keyword);
	    goto free;
	  }
	  break;
	case MAILIMAP_FLAG_KEYWORD:
          if (strcasecmp(flag_fetch->fl_flag->fl_data.fl_keyword,
                  "$Forwarded") == 0) {
            flags->fl_flags |= MAIL_FLAG_FORWARDED;
          }
          else {
            keyword = strdup(flag_fetch->fl_flag->fl_data.fl_keyword);
            if (keyword == NULL)
              goto free;
            r = clist_append(flags->fl_extension, keyword);
            if (r < 0) {
              free(keyword);
              goto free;
            }
          }
	  break;
	case MAILIMAP_FLAG_EXTENSION:
	  /* do nothing */
	  break;
	}
      }
    }
    /*
      MAIL_FLAG_NEW was set for \Recent messages.
      Correct this flag for \Seen messages by unsetting it.
    */
    if ((flags->fl_flags & MAIL_FLAG_SEEN) && (flags->fl_flags & MAIL_FLAG_NEW)) {
      flags->fl_flags &= ~MAIL_FLAG_NEW;
    }
  }

  * result = flags;
  
  return MAIL_NO_ERROR;

 free:
  mail_flags_free(flags);
 err:
  return MAIL_ERROR_MEMORY;
}
@end
