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

#import <Foundation/Foundation.h>

/*!
    @class	CTSMTPConnection
    This is not a class you instantiate! It has only one class method, and that is all you need to send e-mail.
    First use CTCoreMessage to compose an e-mail and then pass the e-mail to the method sendMessage: with
    the necessary server settings and CTSMTPConnection will send the message.
*/

@class CTCoreMessage, CTCoreAddress;

@interface CTSMTPConnection : NSObject {

}
/*!
    @abstract	This method...it sends e-mail.
    @param		message	Just pass in a CTCoreMessage which has the body, subject, from, to etc. that you want
    @param		server The server address
    @param		username The username, if there is none then pass in an empty string. For some servers you may
                have to specify the username as username@domain
    @param		password The password, if there is none then pass in an empty string.
    @param		port The port to use, the standard port is 25
    @param		useTLS Pass in YES, if you want to use SSL/TLS
    @param		useAuth Pass in YES if you would like to use SASL authentication
*/
+ (void)sendMessage:(CTCoreMessage *)message server:(NSString *)server username:(NSString *)username
                    password:(NSString *)password port:(unsigned int)port useTLS:(BOOL)tls useAuth:(BOOL)auth;
@end
