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
 * 3. Neither the name of the libEtPan! project nor the names of its
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

#import <Cocoa/Cocoa.h>

/*!
	@class	@CTCoreAddress
	This is a very simple class designed to make it easier to work with email addresses since many times
	the e-mail address and name are both encoded in the MIME e-mail fields. This class should be very straight
	forward, you can get and set a name and an e-mail address.
*/

@interface CTCoreAddress : NSObject {
	NSString *email;
	NSString *name;
}
/*!
	@abstract Returns a CTCoreAddress with the name and e-mail address set as an empty string.
*/
+ (id)address;

/*!
	@abstract Returns a CTCoreAddress set with the specified name and email.
*/
+ (id)addressWithName:(NSString *)aName email:(NSString *)aEmail;

/*!
	@abstract Returns a CTCoreAddress set with the specified name and email.
*/
- (id)initWithName:(NSString *)aName email:(NSString *)aEmail;

/*!
	@abstract Returns the name as a NSString
*/
- (NSString *)name;

/*!
	@abstract Sets the name.
*/
- (void)setName:(NSString *)aValue;

/*!
	@abstract Returns the e-mail as a NSString
*/
- (NSString *)email;

/*!
	@abstract Sets the e-mail.
*/
- (void)setEmail:(NSString *)aValue;

/*!
	@abstract Works like the typical isEqual: method
*/
- (BOOL)isEqual:(id)object;

/*!
	@abstract Standard description method
*/
- (NSString *)description;
@end
