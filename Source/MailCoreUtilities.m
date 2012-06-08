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
#import "JRLog.h"
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

// From Gabor
BOOL StringStartsWith(NSString *string, NSString *subString) {
    if([string length] < [subString length]) {
        return NO;
    }

    NSString* comp = [string substringToIndex:[subString length]];
    return [comp isEqualToString:subString];
}

NSString *MailCoreDecodeMIMEPhrase(char *data) {
    int err;
    size_t currToken = 0;
    char *decodedSubject;
    NSString *result;

    if (*data != '\0') {
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
