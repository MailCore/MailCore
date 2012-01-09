//
//  CTMIME_HtmlPart.h
//  EazyPractice
//
//  Created by Kaustubh Kabra on 06/01/12.
//  Copyright (c) 2012 Xtremum Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMIME_SinglePart.h"

@interface CTMIME_HtmlPart : CTMIME_SinglePart {
}
+ (id)mimeTextPartWithString:(NSString *)str;
- (id)initWithString:(NSString *)string;
- (void)setString:(NSString *)str;
@end
