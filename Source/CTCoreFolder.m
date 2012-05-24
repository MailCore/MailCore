/*
 * MailCore
 *
 * Copyright (C) 2007 - Matt Ronge
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MailCore project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#import "CTCoreFolder.h"
#import <libetpan/libetpan.h>
#import "CTCoreMessage.h"
#import "CTCoreAccount.h"
#import "MailCoreTypes.h"
#import "CTBareMessage.h"
#import "MailCoreUtilities.h"

// Implementation is in imapdriver_tools.c
int imap_flags_to_flags(struct mailimap_msg_att_dynamic * att_dyn,
                        struct mail_flags ** result);

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
		myFolder = mailfolder_new(storage, (char *)[myPath cStringUsingEncoding:NSUTF8StringEncoding], NULL);	
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
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);	
	connected = YES;
}


- (void)disconnect {
	if(connected)
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
	const char *newPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
	const char *oldPath = [myPath cStringUsingEncoding:NSUTF8StringEncoding];
	
	[self connect];	
	[self unsubscribe];
	err =  mailimap_rename([myAccount session], oldPath, newPath);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);	
	[path retain];
	[myPath release];
	myPath = path;
	[self subscribe];
}


- (void)create {
	int err;
	const char *path = [myPath cStringUsingEncoding:NSUTF8StringEncoding];
	
	err =  mailimap_create([myAccount session], path);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);
	[self connect];
	[self subscribe];	
}


- (void)delete {
	int err;
	const char *path = [myPath cStringUsingEncoding:NSUTF8StringEncoding];
	
	[self connect];
	[self unsubscribe];
	err =  mailimap_delete([myAccount session], path);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);
}


- (void)subscribe {
	int err;
	const char *path = [myPath cStringUsingEncoding:NSUTF8StringEncoding];
	
	[self connect];
	err =  mailimap_subscribe([myAccount session], path);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);
}


- (void)unsubscribe {
	int err;
	const char *path = [myPath cStringUsingEncoding:NSUTF8StringEncoding];
	
	[self connect];
	err =  mailimap_unsubscribe([myAccount session], path);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);	
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
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);	
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
				mail_flags_free(flags);					
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
		if(msg_att != nil) {
			[msgObject setSequenceNumber:msg_att->att_number];
			[messages addObject:msgObject];
		}
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


- (CTCoreMessage *)messageWithUID:(NSString *)uid {
	int err;
	struct mailmessage *msgStruct;
	
	[self connect];
	err = mailfolder_get_message_by_uid([self folderStruct], [uid cStringUsingEncoding:NSUTF8StringEncoding], &msgStruct);
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
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);
	[self check];
}


- (void)expunge {
	int err;
	[self connect];
	err = mailfolder_expunge(myFolder);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);	
}

- (void)copyMessage: (NSString *)path forMessage:(CTCoreMessage *)msg {
	[self connect];

	const char *mbPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
	NSString *uid = [msg uid];
	NSUInteger uidnum = (unsigned int)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:1] doubleValue];
	int err = mailsession_copy_message([self folderSession], uidnum, mbPath);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);		
}

- (void)moveMessage: (NSString *)path forMessage:(CTCoreMessage *)msg {
	[self connect];
	
	const char *mbPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
	NSString *uid = [msg uid];
	NSUInteger uidnum = (unsigned int)[[[uid componentsSeparatedByString:@"-"] objectAtIndex:1] doubleValue];
	int err = mailsession_move_message([self folderSession], uidnum, mbPath);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
						  [NSString stringWithFormat:@"Error number: %d",err]);		
}

- (NSUInteger)unreadMessageCount {
	unsigned int unseenCount = 0;
	unsigned int junk;
	int err;
	
	[self connect];
	err =  mailfolder_status(myFolder, &junk, &junk, &unseenCount);
	IfTrue_RaiseException(err != MAILIMAP_NO_ERROR, CTUnknownError, 
		[NSString stringWithFormat:@"Error number: %d",err]);
	return unseenCount;
}


- (NSUInteger)totalMessageCount {
	[self connect];			
	return [self imapSession]->imap_selection_info->sel_exists;
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
//TODO Can these things be made public in libetpan?
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
