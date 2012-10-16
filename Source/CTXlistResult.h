//
//  CTXlistResult.h
//  MailCore
//
//  Created by Kris Wong on 10/15/12.
//
//

#import <Foundation/Foundation.h>

@interface CTXlistResult : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, strong, readonly) NSArray *flags;

- (void)addFlag:(NSString *)flag;

@end
