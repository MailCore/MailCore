//
//  CTCoreAccount+Extended.h
//  MailCore
//
//  Created by Davide Gullo on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTCoreAccount.h"

@interface CTCoreAccount (Extended)

-(NSMutableDictionary *) foldersWithAttributes:(NSString *)  attribute ;

@end
