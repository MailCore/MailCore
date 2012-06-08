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

#import <libetpan/libetpan.h>
#import <libetpan/imapdriver_tools.h>

#import "CTCoreFolder.h"
#import "CTCoreMessage.h"
#import "CTCoreAccount.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"

int uid_list_to_env_list(clist * fetch_result, struct mailmessage_list ** result,
                        mailsession * session, mailmessage_driver * driver);

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
    int r;
    struct mailimap_fetch_att * fetch_att;
    struct mailimap_fetch_type * fetch_type;
    struct mailimap_set * set;
    clist * fetch_result;

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

// We always fetch UID, RFC822.Size, and Flags
- (NSArray *)messageObjectsForSet:(struct mailimap_set *)set fetchAttributes:(CTFetchAttributes)attrs {
    [self connect];

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
        return nil;
    }

    // Always fetch flags
    fetch_att = mailimap_fetch_att_new_flags();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        return nil;
    }

    // Always fetch RFC822.Size
    fetch_att = mailimap_fetch_att_new_rfc822_size();
    r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if (r != MAILIMAP_NO_ERROR) {
        mailimap_fetch_att_free(fetch_att);
        mailimap_fetch_type_free(fetch_type);
        return nil;
    }

    // We only fetch the body structure if requested
    if (attrs & CTFetchAttrBodyStructure) {
        fetch_att = mailimap_fetch_att_new_bodystructure();
        r = mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
        if (r != MAILIMAP_NO_ERROR) {
            mailimap_fetch_att_free(fetch_att);
            mailimap_fetch_type_free(fetch_type);
            return nil;
        }
    }

    // We only fetch envelope if requested
    if (attrs & CTFetchAttrEnvelope) {
        r = imap_add_envelope_fetch_att(fetch_type);
        if (r != MAIL_NO_ERROR) {
            mailimap_fetch_type_free(fetch_type);
            return nil;
        }
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

    env_list = NULL;
    r = uid_list_to_env_list(fetch_result, &env_list, [self folderSession], imap_message_driver);

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
        if (msg_att == nil)
            return nil;

        uint32_t uid = 0;
        char * references = NULL;
        size_t ref_size = 0;
        struct mailimap_body * imap_body = NULL;
        struct mailimap_envelope * envelope = NULL;

        r = imap_get_msg_att_info(msg_att, &uid, &envelope, &references, &ref_size, NULL, &imap_body);
        if (r != MAIL_NO_ERROR) {
            mailimap_fetch_list_free(fetch_result);
            return nil;
        }

        if (imap_body != NULL) {
            r = imap_body_to_body(imap_body, &body);
            if (r != MAIL_NO_ERROR) {
                mailimap_fetch_list_free(fetch_result);
                return nil;
            }
        }

        if (envelope != NULL) {
            r = imap_env_to_fields(envelope, references, ref_size, &fields);
            if (r != MAIL_NO_ERROR) {
                mailmime_free(body);
                mailimap_fetch_list_free(fetch_result);
                return nil;
            }
        }

        content_message = mailmime_get_content_message();
        if (content_message == NULL) {
            if (fields != NULL)
                mailimf_fields_free(fields);
            mailmime_free(body);
            mailimap_fetch_list_free(fetch_result);
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
            return nil;
        }

        CTCoreMessage* msgObject = [[CTCoreMessage alloc] initWithMessageStruct:msg];
        [msgObject setSequenceNumber:msg_att->att_number];
        if (fields != NULL) {
            [msgObject setFields:fields];
        }
        if (attrs & CTFetchAttrBodyStructure) {
            [msgObject setBodyStructure:new_body];
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

- (NSArray *)messageObjectsFromIndex:(unsigned int)start toIndex:(unsigned int)end withFetchAttributes:(CTFetchAttributes)attrs {
    struct mailimap_set *set = mailimap_set_new_interval(start, end);
    NSArray *results = [self messageObjectsForSet:set fetchAttributes:attrs];
    return results;
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
