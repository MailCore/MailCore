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
- (NSArray *) messagesFullFrom:(NSUInteger)startUID to:(NSUInteger)endUID;
- (NSArray *) getUidsFromLastUID:(NSUInteger)UID;
- (NSArray *) getAll_X_Gm_msgIds;

@end
