//
//  CTCoreFolder+Extended.h
//  MailCore
//
//  Created by Davide Gullo on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTCoreFolder.h"

@interface CTCoreFolder (Extended)

//- (id)initWithPathKeepConnection:(NSString *)path inAccount:(CTCoreAccount *)account;
- (void) setupTempDir;
- (NSArray *) messagesFullFrom:(NSUInteger)startUID to:(NSUInteger)endUID;
- (NSArray *) getUidsFromLastUID:(NSUInteger)UID;
- (NSArray *) getUidsFromUID:(NSUInteger)from to:(NSUInteger)to;
- (NSArray *) getAll_X_Gm_msgIds;
- (long) appendMessageSeen: (CTCoreMessage *) msg withData: (NSData *)msgData;

@end
