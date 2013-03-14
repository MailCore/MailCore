//
//  CTCoreFolder+Extended.m
//  MailCore
//
//  Created by Davide Gullo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <libetpan/libetpan.h>
#import <libetpan/imapdriver_tools.h>

#import "CTCoreAccount.h"
#import "CTCoreFolder+Extended.h"
#import "CTCoreMessage.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"
#import <libetpan/libetpan.h>

#include <unistd.h>

@implementation CTCoreFolder (Extended)
/*
- (id)initWithPathKeepConnection:(NSString *)path inAccount:(CTCoreAccount *)account {
	[self initWithPath:path inAccount:account];
    if (![account isConnected]) {
		BOOL success = [self connect];
		if(!success) {
			return nil;
		}
		connected = YES;
    }
    return self;
}
*/

- (NSArray *) messagesFullFrom:(NSUInteger)startUID to:(NSUInteger)endUID {
	
    /*
	 SET Temporary Directory
	 BugFix: Sandbox doesn't allow to access to /tmp default directory!
     */
    mmap_string_set_tmpdir((const char *) [NSTemporaryDirectory() cStringUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"Temporary Directory used: %@", NSTemporaryDirectory());
	
	
	struct mailimap_set *set = mailimap_set_new_interval(startUID, endUID);
	
    BOOL success = [self connect];
    if (!success) {
        return nil;
    }
	
    NSMutableArray *messages = [NSMutableArray array];
	
    int r;
    struct mailimap_fetch_att * fetch_att;
    struct mailimap_fetch_type * fetch_type;
    struct mailmessage_list * env_list;
	
    clist * fetch_result;
	
    fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
    // Always fetch UID
    fetch_att = mailimap_fetch_att_new_uid();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
    // Always fetch X-GM-MSGID (if available)
    if (mailimap_has_xgmmsgid([self imapSession])) {
        fetch_att = mailimap_fetch_att_new_xgmmsgid();
        r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
        if (r != MAILIMAP_NO_ERROR) {
            mailimap_fetch_att_free(fetch_att);
            mailimap_fetch_type_free(fetch_type);
            self.lastError = MailCoreCreateErrorFromIMAPCode(r);
            return nil;
        }
    }
	
	// Always fetch FLAGS
    fetch_att = mailimap_fetch_att_new_flags();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
    // Always fetch RFC822.SIZE
    fetch_att = mailimap_fetch_att_new_rfc822_size();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
	// ENVELOPE
	r = imap_add_envelope_fetch_att(fetch_type);
	if (r != MAIL_NO_ERROR) {
		mailimap_fetch_type_free(fetch_type);
		self.lastError = MailCoreCreateErrorFromIMAPCode(r);
		return nil;
	}
	
	// BODYSTRUCTURE
	fetch_att = mailimap_fetch_att_new_bodystructure();
	r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	if (r != MAILIMAP_NO_ERROR) {
		mailimap_fetch_att_free(fetch_att);
		mailimap_fetch_type_free(fetch_type);
		self.lastError = MailCoreCreateErrorFromIMAPCode(r);
		return nil;
	}
	
	//RFC822
	fetch_att = mailimap_fetch_att_new_rfc822();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
	
	// Fetch by UID
	r = mailimap_uid_fetch([self imapSession], set, fetch_type, &fetch_result);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
    mailimap_fetch_type_free(fetch_type);
    mailimap_set_free(set);
    
    env_list = NULL;
    r = uid_list_to_env_list(fetch_result, &env_list, [self folderSession], imap_message_driver);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
    r = imap_fetch_result_to_envelop_list(fetch_result, env_list);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
    
    // Parsing of MIME bodies
    int len = carray_count(env_list->msg_tab);
	
    clistiter *fetchResultIter = clist_begin(fetch_result);
    for(int i=0; i<len; i++) {
        struct mailimf_fields * fields = NULL;
        struct mailmime * new_body = NULL;
        struct mailmime_content * content_message = NULL;
        struct mailmime * body = NULL;
		
        struct mailmessage * msg = carray_get(env_list->msg_tab, i);
        struct mailimap_msg_att *msg_att = (struct mailimap_msg_att *)clist_content(fetchResultIter);
        if (msg_att == nil) {
            self.lastError = MailCoreCreateErrorFromIMAPCode(MAIL_ERROR_MEMORY);
            return nil;
        }
		
        uint32_t uid = 0;
        char * references = NULL;
        size_t ref_size = 0;
        struct mailimap_body * imap_body = NULL;
        struct mailimap_envelope * envelope = NULL;
		
		r = imap_get_msg_att_info(msg_att, &uid, &envelope, &references, &ref_size, NULL, &imap_body);
		if (r != MAIL_NO_ERROR) {
			mailimap_fetch_list_free(fetch_result);
			self.lastError = MailCoreCreateErrorFromIMAPCode(r);
			return nil;
		}
		
		if (imap_body != NULL) {
			r = imap_body_to_body(imap_body, &body);
			if (r != MAIL_NO_ERROR) {
				mailimap_fetch_list_free(fetch_result);
				self.lastError = MailCoreCreateErrorFromIMAPCode(r);
				return nil;
			}
		}
		
		if (envelope != NULL) {
			r = imap_env_to_fields(envelope, references, ref_size, &fields);
			if (r != MAIL_NO_ERROR) {
				mailmime_free(body);
				mailimap_fetch_list_free(fetch_result);
				self.lastError = MailCoreCreateErrorFromIMAPCode(r);
				return nil;
			}
		}
		
		content_message = mailmime_get_content_message();
		if (content_message == NULL) {
			if (fields != NULL)
				mailimf_fields_free(fields);
			mailmime_free(body);
			mailimap_fetch_list_free(fetch_result);
			self.lastError = MailCoreCreateErrorFromIMAPCode(MAIL_ERROR_MEMORY);
			return nil;
		}
		
		new_body = mailmime_new(MAILMIME_MESSAGE, NULL,
								0, NULL, content_message,
								NULL, NULL, NULL, NULL, fields, body);
		
		if (new_body == NULL) {
			mailmime_content_free(content_message);
			if (fields != NULL)
				mailimf_fields_free(fields);
			mailmime_free(body);
			mailimap_fetch_list_free(fetch_result);
			self.lastError = MailCoreCreateErrorFromIMAPCode(MAIL_ERROR_MEMORY);
			return nil;
		}

        
        CTCoreMessage* msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
        msgObject.parentFolder = self;
        [msgObject setSequenceNumber:msg_att->att_number];
        if (fields != NULL) {
            [msgObject setFields:fields];
        }
//        if (attrs & CTFetchAttrBodyStructure) {
            [msgObject setBodyStructure:new_body];
//        }
        [messages addObject:msgObject];
        [msgObject release];
		
        fetchResultIter = clist_next(fetchResultIter);
    }
	
    if (env_list != NULL) {
        //I am only freeing the message array because the messages themselves are in use
        carray_free(env_list->msg_tab);
        free(env_list);
    }
    mailimap_fetch_list_free(fetch_result);
	
    return messages;
	
}


- (NSArray *) getUidsFromLastUID:(NSUInteger)UID {
	
    struct mailimap_set *set = mailimap_set_new_interval(UID, 0);
	
    BOOL success = [self connect];
    if (!success) {
        return nil;
    }
	
    NSMutableArray *messages = [NSMutableArray array];
	
    int r;
    struct mailimap_fetch_att * fetch_att;
    struct mailimap_fetch_type * fetch_type;
    struct mailmessage_list * env_list;
	
    clist * fetch_result;
	
    fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
    // Always fetch UID
    fetch_att = mailimap_fetch_att_new_uid();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
    // Always fetch flags
    fetch_att = mailimap_fetch_att_new_flags();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
    
	r = mailimap_uid_fetch([self imapSession], set, fetch_type, &fetch_result);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
		NSLog(@"Error: %@", self.lastError);
        return nil;
    }
	
    mailimap_fetch_type_free(fetch_type);
    mailimap_set_free(set);
	
    env_list = NULL;
    r = uid_list_to_env_list(fetch_result, &env_list, [self folderSession], imap_message_driver);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
    r = imap_fetch_result_to_envelop_list(fetch_result, env_list);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
	
    // Parsing of MIME bodies
    int len = carray_count(env_list->msg_tab);
	
    clistiter *fetchResultIter = clist_begin(fetch_result);
    for(int i=0; i<len; i++) {
        struct mailimf_fields * fields = NULL;
//		struct mailmime * body = NULL;

        struct mailmessage * msg = carray_get(env_list->msg_tab, i);
        struct mailimap_msg_att *msg_att = (struct mailimap_msg_att *)clist_content(fetchResultIter);
        if (msg_att == nil) {
            self.lastError = MailCoreCreateErrorFromIMAPCode(MAIL_ERROR_MEMORY);
            return nil;
        }
		
		uint32_t uid = 0;
		char * references = NULL;
		size_t ref_size = 0;
		struct mailimap_body * imap_body = NULL;
		struct mailimap_envelope * envelope = NULL;
		r = imap_get_msg_att_info(msg_att, &uid, &envelope, &references, &ref_size, NULL, &imap_body);
		if (r != MAIL_NO_ERROR) {
			mailimap_fetch_list_free(fetch_result);
			self.lastError = MailCoreCreateErrorFromIMAPCode(r);
			return nil;
		}
		
		
        CTCoreMessage* msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
        msgObject.parentFolder = self;
        [msgObject setSequenceNumber:msg_att->att_number];
        if (fields != NULL) {
            [msgObject setFields:fields];
        }
        [messages addObject:msgObject];
        [msgObject release];
		
        fetchResultIter = clist_next(fetchResultIter);
    }
	
    if (env_list != NULL) {
        //I am only freeing the message array because the messages themselves are in use
        carray_free(env_list->msg_tab);
        free(env_list);
    }
    mailimap_fetch_list_free(fetch_result);
	
    return messages;
}



-(NSArray *) getAll_X_Gm_msgIds {
    
    struct mailimap_set *set = mailimap_set_new_interval(1, 0);
	
    BOOL success = [self connect];
    if (!success) {
        return nil;
    }
	
    NSMutableArray *messages = [NSMutableArray array];
	
    int r;
    struct mailimap_fetch_att * fetch_att;
    struct mailimap_fetch_type * fetch_type;
    struct mailmessage_list * env_list;
	
    clist * fetch_result;
	
    fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
    // Always fetch UID
    fetch_att = mailimap_fetch_att_new_uid();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
    // Always fetch X-GM-MSGID (if available)
    if (mailimap_has_xgmmsgid([self imapSession])) {
        fetch_att = mailimap_fetch_att_new_xgmmsgid();
        r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
        if (r != MAILIMAP_NO_ERROR) {
            mailimap_fetch_att_free(fetch_att);
            mailimap_fetch_type_free(fetch_type);
            self.lastError = MailCoreCreateErrorFromIMAPCode(r);
            return nil;
        }
    }
    
	r = mailimap_uid_fetch([self imapSession], set, fetch_type, &fetch_result);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
		NSLog(@"Error: %@", self.lastError);
        return nil;
    }
	
    mailimap_fetch_type_free(fetch_type);
    mailimap_set_free(set);
	
    env_list = NULL;
    r = uid_list_to_env_list(fetch_result, &env_list, [self folderSession], imap_message_driver);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
    r = imap_fetch_result_to_envelop_list(fetch_result, env_list);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
	
	
    // Parsing of MIME bodies
    int len = carray_count(env_list->msg_tab);
	
    clistiter *fetchResultIter = clist_begin(fetch_result);
    for(int i=0; i<len; i++) {
        struct mailimf_fields * fields = NULL;
		//		struct mailmime * body = NULL;
		
        struct mailmessage * msg = carray_get(env_list->msg_tab, i);
        struct mailimap_msg_att *msg_att = (struct mailimap_msg_att *)clist_content(fetchResultIter);
        if (msg_att == nil) {
            self.lastError = MailCoreCreateErrorFromIMAPCode(MAIL_ERROR_MEMORY);
            return nil;
        }
		
		uint32_t uid = 0;
		char * references = NULL;
		size_t ref_size = 0;
		struct mailimap_body * imap_body = NULL;
		struct mailimap_envelope * envelope = NULL;
		r = imap_get_msg_att_info(msg_att, &uid, &envelope, &references, &ref_size, NULL, &imap_body);
		if (r != MAIL_NO_ERROR) {
			mailimap_fetch_list_free(fetch_result);
			self.lastError = MailCoreCreateErrorFromIMAPCode(r);
			return nil;
		}
		
		
        CTCoreMessage* msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
        msgObject.parentFolder = self;
        [msgObject setSequenceNumber:msg_att->att_number];
        if (fields != NULL) {
            [msgObject setFields:fields];
        }
        [messages addObject:msgObject];
        [msgObject release];
		
        fetchResultIter = clist_next(fetchResultIter);
    }
	
    if (env_list != NULL) {
        //I am only freeing the message array because the messages themselves are in use
        carray_free(env_list->msg_tab);
        free(env_list);
    }
    mailimap_fetch_list_free(fetch_result);
	
    return messages;
}

 
 
 
@end
