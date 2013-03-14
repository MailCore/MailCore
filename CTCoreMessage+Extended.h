//
//  CTCoreMessage+Extended.h
//  MailCore
//
//  Created by Davide Gullo on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTCoreMessage.h"

@interface CTCoreMessage (Extended)

- (BOOL)fetchMyMessage;
- (char *)my_rfc822;
@end
