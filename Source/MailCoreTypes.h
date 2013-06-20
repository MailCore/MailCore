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

#define DEST_CHARSET "UTF-8"
#define CTContentTypesPath @"/System/Library/Frameworks/Foundation.framework/Resources/types.plist"

/** Constants for fetching messages **/

typedef enum {
    CTFetchAttrDefaultsOnly     = 0,
    CTFetchAttrBodyStructure    = 1 << 0,
    CTFetchAttrEnvelope         = 1 << 1,
    CTFetchAttrRFC822Headers    = 1 << 2
} CTFetchAttributes;

/** Constants for IDLE **/

typedef enum {
    CTIdleNewData = 0,
    CTIdleTimeout,
    CTIdleCancelled,
    CTIdleError,
} CTIdleResult;

/** Connection Constants **/

typedef enum {
    CTSMTPConnectionTypePlain = 0,
    CTSMTPConnectionTypeStartTLS,
    CTSMTPConnectionTypeTLS
} CTSMTPConnectionType;

/* when the connection is plain text */
#define CTConnectionTypePlain       CONNECTION_TYPE_PLAIN
/* when the connection is first plain, then, we want to switch to TLS (secure connection) */
#define CTConnectionTypeStartTLS    CONNECTION_TYPE_STARTTLS
/* the connection is first plain, then, we will try to switch to TLS */
#define CTConnectionTypeTryStartTLS CONNECTION_TYPE_TRY_STARTTLS
/* the connection is over TLS */
#define CTConnectionTypeTLS         CONNECTION_TYPE_TLS

#define CTImapAuthTypePlain         IMAP_AUTH_TYPE_PLAIN

/** List of Message Flags **/

#define CTFlagNew			MAIL_FLAG_NEW
#define CTFlagSeen			MAIL_FLAG_SEEN
#define CTFlagFlagged		MAIL_FLAG_FLAGGED
#define CTFlagDeleted		MAIL_FLAG_DELETED
#define CTFlagAnswered		MAIL_FLAG_ANSWERED
#define CTFlagForwarded		MAIL_FLAG_FORWARDED
#define CTFlagCancelled 	MAIL_FLAG_CANCELLED

/** Async SMTP Status **/

typedef enum 
{
    CTSMTPAsyncSuccess = 0,
    CTSMTPAsyncCanceled = 1,
    CTSMTPAsyncError = 2
} CTSMTPAsyncStatus;
