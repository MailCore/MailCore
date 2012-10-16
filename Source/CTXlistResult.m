//
//  CTXlistResult.m
//  MailCore
//
//  Created by Kris Wong on 10/15/12.
//
//

#import "CTXlistResult.h"

@implementation CTXlistResult
{
    NSMutableArray *_flags;
}

@synthesize name, flags = _flags;

- (id)init
{
    self = [super init];
    if (self) {
        _flags = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addFlag:(NSString *)flag
{
    [_flags addObject:flag];
}

@end
