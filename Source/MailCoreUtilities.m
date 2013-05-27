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

#import "MailCoreUtilities.h"
#import "MailCoreTypes.h"

/* direction is 1 for send, 0 for receive, -1 when it does not apply */
void mailcore_logger(int direction, const char * str, size_t size) {
    char *str2 = malloc(size+1);
    strncpy(str2,str,size);
    str2[size] = 0;
    if (direction == 1) {
        printf("%s\n", str2);
    }
    else if (direction == 0) {
        printf("%s\n", str2);
    }
    else {
        printf("%s\n", str2);
    }
    free(str2);
}


void MailCoreEnableLogging() {
    mailstream_debug = 1;
    mailstream_logger = mailcore_logger;
}

void MailCoreDisableLogging() {
    mailstream_debug = 0;
    mailstream_logger = nil;
}

NSError* MailCoreCreateError(int errcode, NSString *description) {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:MailCoreErrorDomain code:errcode userInfo:errorDetail];
}

NSError* MailCoreCreateErrorFromSMTPCode(int errcode) {
    NSString *description = @"Unknown error";
    
    switch (errcode) {
        case MAILSMTP_ERROR_AUTH_LOGIN:
            description = @"Invalid username or password";
            break;
            
        default: {
            const char *errStr = mailsmtp_strerror(errcode);
            if (errStr) {
                description = [[[NSString alloc] initWithCString:errStr encoding:NSUTF8StringEncoding] autorelease];
            }
            break;
        }
    }
    return MailCoreCreateError(errcode, description);
}

NSError* MailCoreCreateErrorFromIMAPCode(int errcode) {
    NSString *description = @"";
    switch (errcode) {
        case MAILIMAP_ERROR_BAD_STATE:
            description = @"Bad state";
            break;
        case MAILIMAP_ERROR_STREAM:
            description = @"Stream error"; // Used to be @"Lost connection"
            break;
        case MAILIMAP_ERROR_PARSE:
            description = @"Parse error";
            break;
        case MAILIMAP_ERROR_CONNECTION_REFUSED:
            description = @"Connection refused";
            break;
        case MAILIMAP_ERROR_MEMORY:
            description = @"Memory Error";
            break;
        case MAILIMAP_ERROR_FATAL:
            description = @"IMAP connection lost"; // I renamed this to calm users
            break;
        case MAILIMAP_ERROR_PROTOCOL:
            description = @"Protocol Error";
            break;
        case MAILIMAP_ERROR_DONT_ACCEPT_CONNECTION:
            description = @"Connection not accepted";
            break;
        case MAILIMAP_ERROR_APPEND:
            description = @"Append error";
            break;
        case MAILIMAP_ERROR_NOOP:
            description = @"NOOP error";
            break;
        case MAILIMAP_ERROR_LOGOUT:
            description = @"Logout error";
            break;
        case MAILIMAP_ERROR_CAPABILITY:
            description = @"Capability error";
            break;
        case MAILIMAP_ERROR_CHECK:
            description = @"Check command error";
            break;
        case MAILIMAP_ERROR_CLOSE:
            description = @"Close command error";
            break;
        case MAILIMAP_ERROR_EXPUNGE:
            description = @"Expunge command error";
            break;
        case MAILIMAP_ERROR_COPY:
            description = @"Copy command error";
            break;
        case MAILIMAP_ERROR_UID_COPY:
            description = @"UID copy command error";
            break;
        case MAILIMAP_ERROR_CREATE:
            description = @"Create command error";
            break;
        case MAILIMAP_ERROR_DELETE:
            description = @"Delete error";
            break;
        case MAILIMAP_ERROR_EXAMINE:
            description = @"Examine command error";
            break;
        case MAILIMAP_ERROR_FETCH:
            description = @"Fetch command error";
            break;
        case MAILIMAP_ERROR_UID_FETCH:
            description = @"UID fetch command error";
            break;
        case MAILIMAP_ERROR_LIST:
            description = @"List command error";
            break;
        case MAILIMAP_ERROR_LOGIN:
            description = @"Login error";
            break;
        case MAILIMAP_ERROR_LSUB:
            description = @"Lsub error";
            break;
        case MAILIMAP_ERROR_RENAME:
            description = @"Rename error";
            break;
        case MAILIMAP_ERROR_SEARCH:
            description = @"Search error";
            break;
        case MAILIMAP_ERROR_UID_SEARCH:
            description = @"Uid search error";
            break;
        case MAILIMAP_ERROR_SELECT:
            description = @"Select cmnd error";
            break;
        case MAILIMAP_ERROR_STATUS:
            description = @"Status cmnd error";
            break;
        case MAILIMAP_ERROR_STORE:
            description = @"Store cmnd error";
            break;
        case MAILIMAP_ERROR_UID_STORE:
            description = @"Uid store cmd error";
            break;
        case MAILIMAP_ERROR_SUBSCRIBE:
            description = @"Subscribe error";
            break;
        case MAILIMAP_ERROR_UNSUBSCRIBE:
            description = @"Unsubscribe error";
            break;
        case MAILIMAP_ERROR_STARTTLS:
            description = @"StartTLS error";
            break;
        case MAILIMAP_ERROR_INVAL:
            description = @"Inval cmd error";
            break;
        case MAILIMAP_ERROR_EXTENSION:
            description = @"Extension error";
            break;
        case MAILIMAP_ERROR_SASL:
            description = @"SASL error";
            break;
        case MAILIMAP_ERROR_SSL:
            description = @"SSL error";
            break;
        // the following are from maildriver_errors.h
        case MAIL_ERROR_PROTOCOL:
            description = @"Protocol error";
            break;
        case MAIL_ERROR_CAPABILITY:
            description = @"Capability error";
            break;
        case MAIL_ERROR_CLOSE:
            description = @"Close error";
            break;
        case MAIL_ERROR_FATAL:
            description = @"Fatal error";
            break;
        case MAIL_ERROR_READONLY:
            description = @"Readonly error";
            break;
        case MAIL_ERROR_NO_APOP:
            description = @"No APOP error";
            break;
        case MAIL_ERROR_COMMAND_NOT_SUPPORTED:
            description = @"Cmd not supported";
            break;
        case MAIL_ERROR_NO_PERMISSION:
            description = @"No permission";
            break;
        case MAIL_ERROR_PROGRAM_ERROR:
            description = @"Program error";
            break;
        case MAIL_ERROR_SUBJECT_NOT_FOUND:
            description = @"Subject not found";
            break;
        case MAIL_ERROR_CHAR_ENCODING_FAILED:
            description = @"Encoding failed";
            break;
        case MAIL_ERROR_SEND:
            description = @"Send error";
            break;
        case MAIL_ERROR_COMMAND:
            description = @"Command error";
            break;
        case MAIL_ERROR_SYSTEM:
            description = @"System error";
            break;
        case MAIL_ERROR_UNABLE:
            description = @"Unable error";
            break;
        case MAIL_ERROR_FOLDER:
            description = @"Folder errror";
            break;
        default:
            description = [NSString stringWithFormat:@"Error: %d", errcode];
            break;
    }
    return MailCoreCreateError(errcode, description);
}

NSString *MailCoreDecodeMIMEPhrase(char *data) {
    int err;
    size_t currToken = 0;
    char *decodedSubject;
    NSString *result;

    if (data && *data != '\0') {
        err = mailmime_encoded_phrase_parse(DEST_CHARSET, data, strlen(data),
                                            &currToken, DEST_CHARSET, &decodedSubject);

        if (err != MAILIMF_NO_ERROR) {
            if (decodedSubject == NULL)
                free(decodedSubject);
            return nil;
        }
    } else {
        return @"";
    }

    result = [NSString stringWithCString:decodedSubject encoding:NSUTF8StringEncoding];
    free(decodedSubject);
    return result;
}

NSArray * MailCoreStringArrayFromClist(clist *list) {
  clistiter *iter;
  NSMutableArray *stringSet = [NSMutableArray array];
	char *string;
	
  if(list == NULL)
    return stringSet;
	
  for(iter = clist_begin(list); iter != NULL; iter = clist_next(iter)) {
    string = clist_content(iter);
    NSString *strObj = [[NSString alloc] initWithUTF8String:string];
    [stringSet addObject:strObj];
    [strObj release];
  }
	
  return stringSet;
}

clist *MailCoreClistFromStringArray(NSArray *strings) {
	clist * str_list = clist_new();
  
	for (NSString *str in strings) {
		clist_append(str_list, strdup([str UTF8String]));
	}
  
	return str_list;
}
