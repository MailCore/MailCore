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


#import "CTMIME_MessagePart.h"
#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"
#import "CTMIMEFactory.h"
#import "MailCoreUtilities.h"

@implementation CTMIME_MessagePart

@synthesize rfc822Headers = myRFC822Headers;

- (NSDictionary *)rfc822Headers {
    if (!myRFC822Headers) {
        NSMutableDictionary *rfc822Headers = nil;
        if (myFields && myFields->fld_list) {
            rfc822Headers = [[NSMutableDictionary alloc] initWithCapacity:myFields->fld_list->count];
            clistiter *iter = NULL;
            clist * headers = myFields->fld_list;
            
            for (iter = clist_begin(headers); iter != NULL; iter = clist_next(iter)) {
                struct mailimf_field * field = clist_content(iter);
                
                switch (field->fld_type) {
                    case MAILIMF_FIELD_SUBJECT:
                        rfc822Headers[@"Subject"] = [NSString stringWithUTF8String:field->fld_data.fld_subject->sbj_value];
                        break;
                    case MAILIMF_FIELD_MESSAGE_ID:
                        rfc822Headers[@"Message-ID"] = [NSString stringWithUTF8String:field->fld_data.fld_message_id->mid_value];
                        break;
                    case MAILIMF_FIELD_SENDER:
                        rfc822Headers[@"Sender"] = MailCoreAddressRepresentationFromMailBox(field->fld_data.fld_sender->snd_mb);
                        break;
                    case MAILIMF_FIELD_FROM:
                        rfc822Headers[@"From"] = MailCoreAddressRepresentationArrayFromMailBoxClist(field->fld_data.fld_from->frm_mb_list->mb_list);
                        break;
                    case MAILIMF_FIELD_TO:
                        rfc822Headers[@"To"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_to->to_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_CC:
                        rfc822Headers[@"CC"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_cc->cc_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_BCC:
                        rfc822Headers[@"BCC"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_bcc->bcc_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_REPLY_TO:
                        rfc822Headers[@"Reply-To"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_reply_to->rt_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_IN_REPLY_TO:
                        rfc822Headers[@"In-Reply-To"] = MailCoreStringArrayFromClist(field->fld_data.fld_in_reply_to->mid_list);
                        break;
                    case MAILIMF_FIELD_REFERENCES:
                        rfc822Headers[@"References"] = MailCoreStringArrayFromClist(field->fld_data.fld_references->mid_list);
                        break;
                    case MAILIMF_FIELD_ORIG_DATE:
                        rfc822Headers[@"Date"] = MailCoreDateFromMailIMAPDateTime(field->fld_data.fld_orig_date->dt_date_time);
                        break;
                    case MAILIMF_FIELD_RESENT_MSG_ID:
                        rfc822Headers[@"Recent-Message-ID"] = [NSString stringWithUTF8String:field->fld_data.fld_resent_msg_id->mid_value];
                        break;
                    case MAILIMF_FIELD_RESENT_SENDER:
                        rfc822Headers[@"Resent-Sender"] = MailCoreAddressRepresentationFromMailBox(field->fld_data.fld_resent_sender->snd_mb);
                        break;
                    case MAILIMF_FIELD_RESENT_FROM:
                        rfc822Headers[@"Resent-From"] = MailCoreAddressRepresentationArrayFromMailBoxClist(field->fld_data.fld_resent_from->frm_mb_list->mb_list);
                        break;
                    case MAILIMF_FIELD_RESENT_TO:
                        rfc822Headers[@"Resent-To"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_resent_to->to_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_RESENT_CC:
                        rfc822Headers[@"Resent-CC"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_resent_cc->cc_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_RESENT_BCC:
                        rfc822Headers[@"Resent-BCC"] = MailCoreAddressRepresentationArrayFromAddressClist(field->fld_data.fld_resent_bcc->bcc_addr_list->ad_list);
                        break;
                    case MAILIMF_FIELD_RESENT_DATE:
                        rfc822Headers[@"Resent-Date"] = MailCoreDateFromMailIMAPDateTime(field->fld_data.fld_resent_date->dt_date_time);
                        break;
                        
                    case MAILIMF_FIELD_RETURN_PATH:
                        rfc822Headers[@"Return-Path"] = [NSString stringWithUTF8String:field->fld_data.fld_return_path->ret_path->pt_addr_spec];
                        break;
                        
                    case MAILIMF_FIELD_KEYWORDS:
                        rfc822Headers[@"Keywords"] = MailCoreStringArrayFromClist(field->fld_data.fld_keywords->kw_list);
                        break;
                    case MAILIMF_FIELD_COMMENTS:
                        rfc822Headers[@"Comments"] = [NSString stringWithUTF8String:field->fld_data.fld_comments->cm_value];
                        break;
                    case MAILIMF_FIELD_OPTIONAL_FIELD: {
                        NSString *fieldname = [NSString stringWithUTF8String:field->fld_data.fld_optional_field->fld_name];
                        NSString *fieldValue = [NSString stringWithUTF8String:field->fld_data.fld_optional_field->fld_value];
                        if (fieldname && fieldValue) {
                            rfc822Headers[fieldname] = fieldValue;
                        }
                    }
                        
                    default:
                        break;
                }
            }
        }
        
        myRFC822Headers = [rfc822Headers ?: @{} copy];
    }
    
    return myRFC822Headers;
}

+ (id)mimeMessagePartWithContent:(CTMIME *)mime {
    return [[[CTMIME_MessagePart alloc] initWithContent:mime] autorelease];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime 
              forMessage:(struct mailmessage *)message {
    self = [super initWithMIMEStruct:mime forMessage:message];
    if (self) {
        struct mailmime *content = mime->mm_data.mm_message.mm_msg_mime;
        myMessageContent = [[CTMIMEFactory createMIMEWithMIMEStruct:content
                                                         forMessage:message] retain];
        myFields = mime->mm_data.mm_message.mm_fields;
        
        self.filename = MailCoreGetFileNameFromMIME(mime);
    }
    return self;
}

- (id)initWithContent:(CTMIME *)messageContent {
    self = [super init];
    if (self) {
        [self setContent:messageContent];
    }
    return self;
}

- (void)dealloc {
    [myMessageContent release];
    [super dealloc];
}

- (void)setContent:(CTMIME *)aContent {
    [aContent retain];
    [myMessageContent release];
    myMessageContent = aContent;
}

- (id)content {
    return myMessageContent;
}

- (struct mailmime *)buildMIMEStruct {
    struct mailmime *mime = mailmime_new_message_data([myMessageContent buildMIMEStruct]);
    if (myFields != NULL) {
        mailmime_set_imf_fields(mime, myFields);
    }
    return mime;
}

- (void)setIMFFields:(struct mailimf_fields *)imfFields {
    myFields = imfFields;
}
@end
