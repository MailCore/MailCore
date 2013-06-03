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


#import "CTSearchKeyTransformer.h"

typedef NS_ENUM(NSInteger, CTSearchKey) {
  CTSearchUnknownKey = -1,
  CTSearchAnsweredKey = 0,
  CTSearchDeletedKey = 1,
  CTSearchDraftKey = 2,
  CTSearchFlaggedKey,
  CTSearchRecentKey,
  CTSearchSeenKey,
  CTSearchKeyworkKey,
  CTSearchSizeKey,
  CTSearchInternalDateKey,
  CTSearchDateKey,
  CTSearchCCKey,
  CTSearchBCCKey,
  CTSearchToKey,
  CTSearchFromKey,
  CTSearchTextKey,
  CTSearchSubjectKey,
  CTSearchBodyKey,
  CTSearchHeaderKey
};

typedef NS_ENUM(NSInteger, CTSearchAttributeType){
  CTSearchAttributeNoneType,
  CTSearchAttributeStringType,
  CTSearchAttributeDateType,
  CTSearchAttributeNumberType
};


@interface CTSearchKeyTransformer ()

@property (readonly) NSSet *defaultIMAPSearchKeys;
@property (readonly) NSSet *supportKeys;

@property (readonly) NSDictionary *booleanFlags;

@end


@implementation CTSearchKeyTransformer

- (id)init {
  self = [super init];
  if (self) {
    self->_defaultIMAPSearchKeys = [[NSSet alloc] initWithArray:@[ @"ALL", @"ANSWERED", @"BCC", @"BEFORE", @"BODY", @"CC", @"DELETED", @"DRAFT", @"FLAGGED", @"FROM", @"HEADER", @"KEYWORD", @"LARGER", @"NEW", @"NOT", @"OLD", @"ON", @"OR", @"RECENT", @"SEEN", @"SENTBEFORE", @"SENTON", @"SENTSINCE", @"SINCE", @"SMALLER", @"SUBJECT", @"TEXT", @"TO", @"UID", @"UNANSWERED", @"UNDELETED", @"UNDRAFT", @"UNFLAGGED", @"UNKEYWORD", @"UNSEEN" ]];
    self->_booleanFlags = @{ @"ANSWERED" : @"UNANSWERED", @"UNANSWERED" : @"ANSWERED", @"DELETED" : @"UNDELETED", @"UNDELETED" : @"DELETED", @"DRAFT" : @"UNDRAFT", @"UNDRAFT" : @"DRAFT", @"FLAGGED" : @"UNFLAGGED", @"UNFLAGGED" : @"FLAGGED", @"NEW" : @"OLD", @"RECENT" : @"OLD", @"OLD" : @"RECENT", @"SEEN" : @"UNSEEN", @"UNSEEN" : @"SEEN" };
  }
  
  return self;
}

- (struct mailimap_search_key *)newSearchKeyFromPredicate:(NSPredicate *)predicate {
  if (!predicate) {
    return NULL;
  }
  
  struct mailimap_search_key *mailimap_search_key = NULL;
  if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
    NSComparisonPredicate *comparisonPredicate = (NSComparisonPredicate *)predicate;
    NSExpression *leftExpression = comparisonPredicate.leftExpression;
    NSExpression *rightExpression = comparisonPredicate.rightExpression;
    
    NSString *key = nil;
    id value = nil;
    if (leftExpression.expressionType == NSKeyPathExpressionType) {
      key = leftExpression.keyPath.uppercaseString;
      value = rightExpression.constantValue;
    } else if (rightExpression.expressionType == NSKeyPathExpressionType) {
      key = rightExpression.keyPath.uppercaseString;
      value = leftExpression.constantValue;
    }
    
    if ([key hasPrefix:@"IS"]) {
      key = [key substringFromIndex:@"IS".length];
    }
    
    CTSearchKey searchKey = CTSearchUnknownKey;
    if ([key isEqualToString:@"NEW"] || [key isEqualToString:@"OLD"] ||
        [key isEqualToString:@"RECENT"] ||
        [key isEqualToString:@"ANSWERED"] || [key isEqualToString:@"UNANSWERED"] ||
        [key isEqualToString:@"DELETED"] || [key isEqualToString:@"UNDELETED"] ||
        [key isEqualToString:@"DRAFT"] || [key isEqualToString:@"UNDRAFT"] ||
        [key isEqualToString:@"FLAGGED"] || [key isEqualToString:@"UNFLAGGED"] ||
        [key isEqualToString:@"SEEN"] || [key isEqualToString:@"UNSEEN"]) {
      BOOL isNeglet = ((comparisonPredicate.predicateOperatorType == NSEqualToPredicateOperatorType &&
                        ![value boolValue]) ||
                       (comparisonPredicate.predicateOperatorType == NSNotEqualToPredicateOperatorType &&
                        [value boolValue]));
      BOOL isUNKey = [key hasPrefix:@"UN"] ^ isNeglet;
      
      NSInteger search_key = 0;
      if ([key hasSuffix:@"ANSWERED"]) {
        search_key = !isUNKey ? MAILIMAP_SEARCH_KEY_ANSWERED : MAILIMAP_SEARCH_KEY_UNANSWERED;
      } else if ([key hasSuffix:@"DRAFT"]) {
        search_key = !isUNKey ? MAILIMAP_SEARCH_KEY_DRAFT : MAILIMAP_SEARCH_KEY_UNDRAFT;
      } else if ([key hasSuffix:@"DELETED"]) {
        search_key = !isUNKey ? MAILIMAP_SEARCH_KEY_DELETED : MAILIMAP_SEARCH_KEY_UNDELETED;
      } else if ([key hasSuffix:@"FLAGGED"]) {
        search_key = !isUNKey ? MAILIMAP_SEARCH_KEY_FLAGGED : MAILIMAP_SEARCH_KEY_UNFLAGGED;
      } else if ([key hasSuffix:@"SEEN"]) {
        search_key = !isUNKey ? MAILIMAP_SEARCH_KEY_SEEN : MAILIMAP_SEARCH_KEY_UNSEEN;
      } else if ([key isEqualToString:@"RECENT"]) {
        search_key = !isNeglet ? MAILIMAP_SEARCH_KEY_RECENT : MAILIMAP_SEARCH_KEY_OLD;
      } else if ([key isEqualToString:@"NEW"]) {
        search_key = !isNeglet ? MAILIMAP_SEARCH_KEY_NEW : MAILIMAP_SEARCH_KEY_OLD;
      } else if ([key isEqualToString:@"OLD"]) {
        search_key = !isNeglet ? MAILIMAP_SEARCH_KEY_OLD : MAILIMAP_SEARCH_KEY_NEW;
      }
      
      mailimap_search_key = mailimap_search_key_new(search_key, NULL, NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                    NULL, NULL, 0, NULL, NULL, NULL, NULL,
                                                    NULL, NULL, 0, NULL, NULL, NULL);
    } else if ([key isEqualToString:@"KEYWORD"] || [key isEqualToString:@"UNKEYWORD"] ||
               [key rangeOfString:@"CC"].location != NSNotFound || [key rangeOfString:@"BCC"].location != NSNotFound ||
               [key rangeOfString:@"TO"].location != NSNotFound || [key rangeOfString:@"FROM"].location != NSNotFound ||
               [key isEqualToString:@"TEXT"] || [key isEqualToString:@"SUBJECT"] ||
               [key isEqualToString:@"BODY"]) {
      searchKey = CTSearchKeyworkKey;
      
      struct mailimap_search_key * (* search_key_function)(char *);
      if ([key isEqualToString:@"KEYWORD"]) {
        search_key_function = &mailimap_search_key_new_keyword;
      } else if ([key isEqualToString:@"UNKEYWORD"]) {
        search_key_function = &mailimap_search_key_new_unkeyword;
      } else if ([key rangeOfString:@"CC"].location != NSNotFound) {
        search_key_function = &mailimap_search_key_new_cc;
      } else if ([key rangeOfString:@"BCC"].location != NSNotFound) {
        search_key_function = &mailimap_search_key_new_bcc;
      } else if ([key rangeOfString:@"TO"].location != NSNotFound) {
        search_key_function = &mailimap_search_key_new_to;
      } else if ([key rangeOfString:@"FROM"].location != NSNotFound) {
        search_key_function = &mailimap_search_key_new_from;
      } else if ([key isEqualToString:@"TEXT"]) {
        search_key_function = &mailimap_search_key_new_text;
      } else if ([key isEqualToString:@"SUBJECT"]) {
        search_key_function = &mailimap_search_key_new_subject;
      } else if ([key isEqualToString:@"BODY"]) {
        search_key_function = &mailimap_search_key_new_body;
      }
      
      if ([value isKindOfClass:[NSString class]]) {
        char * argument = strdup([value UTF8String]);
        mailimap_search_key = search_key_function(argument);
      } else if ([value isKindOfClass:[NSArray class]]) {
        mailimap_search_key = mailimap_search_key_new_multiple_empty();
        for (NSString *val in value) {
          char * argument = strdup([val UTF8String]);
          struct mailimap_search_key * sub_search_key = search_key_function(argument);
          if (sub_search_key) {
            mailimap_search_key_multiple_add(mailimap_search_key, sub_search_key);
          }
        }
      }
    } else if ([key isEqualToString:@"SIZE"] || [key isEqualToString:@"SMALLER"] ||
               [key isEqualToString:@"LARGER"]) {
      searchKey = CTSearchSizeKey;
      if (([key isEqualToString:@"SIZE"]  &&
           (comparisonPredicate.predicateOperatorType == NSGreaterThanOrEqualToPredicateOperatorType ||
            comparisonPredicate.predicateOperatorType == NSGreaterThanPredicateOperatorType)) ||
          [key isEqualToString:@"LARGER"]) {
        mailimap_search_key = mailimap_search_key_new_larger([value unsignedIntValue]);
      } else if (([key isEqualToString:@"SIZE"]  &&
                  (comparisonPredicate.predicateOperatorType == NSLessThanOrEqualToPredicateOperatorType ||
                   comparisonPredicate.predicateOperatorType == NSLessThanPredicateOperatorType)) ||
                 [key isEqualToString:@"SMALLER"]) {
        mailimap_search_key = mailimap_search_key_new_larger([value unsignedIntValue]);
      }
    } else if ([key isEqualToString:@"INTERNALDATE"]) {
      searchKey = CTSearchInternalDateKey;
      NSDate *date = nil;
      NSCalendar *calendar = [NSCalendar currentCalendar];
      if ([value isKindOfClass:[NSDate class]]) {
        date = value;
      } else if ([value isKindOfClass:NSDateComponents.class]) {
        date = [calendar dateFromComponents:value];;
      }
      
      switch (comparisonPredicate.predicateOperatorType) {
        case NSEqualToPredicateOperatorType:
          mailimap_search_key = mailimap_search_key_new_on(mailimap_dateFromDate(date));
          break;
          
        case NSGreaterThanPredicateOperatorType: {
          NSDateComponents *carryComponents = [[NSDateComponents alloc] init];
          [carryComponents setDay:1];
          date = [calendar dateByAddingComponents:carryComponents toDate:date options:0];
        }
        case NSGreaterThanOrEqualToPredicateOperatorType:
          mailimap_search_key = mailimap_search_key_new_since(mailimap_dateFromDate(date));
          break;
          
        case NSLessThanPredicateOperatorType: {
          NSDateComponents *carryComponents = [[NSDateComponents alloc] init];
          [carryComponents setDay:-1];
          date = [calendar dateByAddingComponents:carryComponents toDate:date options:0];
        }

        case NSLessThanOrEqualToPredicateOperatorType:
          mailimap_search_key = mailimap_search_key_new_before(mailimap_dateFromDate(date));
          
        case NSBetweenPredicateOperatorType: {
          NSExpression *valueExpression = comparisonPredicate.rightExpression;

          NSDate *fromDate = nil;
          NSDate *toDate = nil;
          id from = valueExpression.constantValue[0];
          id to = valueExpression.constantValue[1];
          if ([from isKindOfClass:NSDate.class]) {
            fromDate = from;
          } else if ([from isKindOfClass:[NSDateComponents class]]) {
            fromDate = [calendar dateFromComponents:from];
          }
          if ([to isKindOfClass:NSDate.class]) {
            toDate = to;
          } else if ([to isKindOfClass:[NSDateComponents class]]) {
            toDate = [calendar dateFromComponents:to];
          }
          
          mailimap_search_key = mailimap_search_key_new_multiple_empty();
          struct mailimap_search_key * from_searh_key = mailimap_search_key_new_since(mailimap_dateFromDate(fromDate));
          struct mailimap_search_key * to_searh_key = mailimap_search_key_new_before(mailimap_dateFromDate(toDate));
          if (from_searh_key && to_searh_key) {
            mailimap_search_key_multiple_add(mailimap_search_key, from_searh_key);
            mailimap_search_key_multiple_add(mailimap_search_key, to_searh_key);
          }
        }
          
        default:
          break;
      }
    } else if ([key isEqualToString:@"DATE"] || [key isEqualToString:@"SENTDATE"]) {
      searchKey = CTSearchDateKey;
      
      NSDate *date = nil;
      NSCalendar *calendar = [NSCalendar currentCalendar];
      if ([value isKindOfClass:[NSDate class]]) {
        date = value;
      } else if ([value isKindOfClass:NSDateComponents.class]) {
        date = [calendar dateFromComponents:value];;
      }
      
      switch (comparisonPredicate.predicateOperatorType) {
        case NSEqualToPredicateOperatorType:
          mailimap_search_key = mailimap_search_key_new_senton(mailimap_dateFromDate(date));
          break;
          
        case NSGreaterThanPredicateOperatorType: {
          NSDateComponents *carryComponents = [[NSDateComponents alloc] init];
          [carryComponents setDay:1];
          date = [calendar dateByAddingComponents:carryComponents toDate:date options:0];
        }
        case NSGreaterThanOrEqualToPredicateOperatorType:
          mailimap_search_key = mailimap_search_key_new_sentsince(mailimap_dateFromDate(date));
          break;
          
        case NSLessThanPredicateOperatorType: {
          NSDateComponents *carryComponents = [[NSDateComponents alloc] init];
          [carryComponents setDay:-1];
          date = [calendar dateByAddingComponents:carryComponents toDate:date options:0];
        }
          
        case NSLessThanOrEqualToPredicateOperatorType:
          mailimap_search_key = mailimap_search_key_new_sentbefore(mailimap_dateFromDate(date));
          
        case NSBetweenPredicateOperatorType: {
          NSExpression *valueExpression = comparisonPredicate.rightExpression;
          
          NSDate *fromDate = nil;
          NSDate *toDate = nil;
          id from = valueExpression.constantValue[0];
          id to = valueExpression.constantValue[1];
          if ([from isKindOfClass:NSDate.class]) {
            fromDate = from;
          } else if ([from isKindOfClass:[NSDateComponents class]]) {
            fromDate = [calendar dateFromComponents:from];
          }
          if ([to isKindOfClass:NSDate.class]) {
            toDate = to;
          } else if ([to isKindOfClass:[NSDateComponents class]]) {
            toDate = [calendar dateFromComponents:to];
          }
          
          mailimap_search_key = mailimap_search_key_new_multiple_empty();
          struct mailimap_search_key * from_searh_key = mailimap_search_key_new_sentsince(mailimap_dateFromDate(fromDate));
          struct mailimap_search_key * to_searh_key = mailimap_search_key_new_sentbefore(mailimap_dateFromDate(toDate));
          if (from_searh_key && to_searh_key) {
            mailimap_search_key_multiple_add(mailimap_search_key, from_searh_key);
            mailimap_search_key_multiple_add(mailimap_search_key, to_searh_key);
          }
        }
          
        default:
          break;
      }
    } else {
      char * key_string = strdup([key UTF8String]);
      if ([value isKindOfClass:[NSString class]]) {
        char * argument = strdup([value UTF8String]);
        mailimap_search_key = mailimap_search_key_new_header(key_string, argument);
      } else if ([value isKindOfClass:[NSArray class]]) {
        mailimap_search_key = mailimap_search_key_new_multiple_empty();
        for (NSString *val in value) {
          char * argument = strdup([val UTF8String]);
          struct mailimap_search_key * sub_search_key = mailimap_search_key_new_header(key_string, argument);
          if (sub_search_key) {
            mailimap_search_key_multiple_add(mailimap_search_key, sub_search_key);
          }
        }
      }
    }
  } else if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
    NSCompoundPredicate *compoundPredicate = (NSCompoundPredicate *)predicate;
    switch (compoundPredicate.compoundPredicateType) {
      case NSAndPredicateType: {
        mailimap_search_key = mailimap_search_key_new_multiple_empty();
        for (NSPredicate *subPredicate in compoundPredicate.subpredicates) {
          struct mailimap_search_key * sub_search_key = [self newSearchKeyFromPredicate:subPredicate];
          if (sub_search_key) {
            mailimap_search_key_multiple_add(mailimap_search_key, sub_search_key);
          }
        }
        break;
      }
      case NSOrPredicateType: {
        for (NSPredicate *subPredicate in compoundPredicate.subpredicates) {
          struct mailimap_search_key * sub_search_key = [self newSearchKeyFromPredicate:subPredicate];
          if (!mailimap_search_key) {
            mailimap_search_key = sub_search_key;
          } else if (sub_search_key) {
            mailimap_search_key = mailimap_search_key_new_or(mailimap_search_key, sub_search_key);
          }
        }
        break;
      }
        
      case NSNotPredicateType: {
        NSPredicate *subPredicate = compoundPredicate.subpredicates.lastObject;
        struct mailimap_search_key * origin_search_key = [self newSearchKeyFromPredicate:subPredicate];
        mailimap_search_key = mailimap_search_key_new_not(origin_search_key);
      }
        
      default:
        break;
    }
  }
  
  return mailimap_search_key;
}

- (struct mailimap_sort_key *)newSortKeyFromSortDescriptors:(NSArray *)sortDescriptors {
  struct mailimap_sort_key * sort_key = mailimap_sort_key_new_multiple_empty();
  for (NSSortDescriptor *sortDescriptor in sortDescriptors) {
    NSString *key = sortDescriptor.key.uppercaseString;
    struct mailimap_sort_key * sort_att = nil;
    if ([key isEqualToString:@"ARRIVAL"]) {
      sort_att = mailimap_sort_key_new_arrival(!sortDescriptor.ascending);
    } else if ([key isEqualToString:@"CC"]) {
      sort_att = mailimap_sort_key_new_cc(!sortDescriptor.ascending);
    } else if ([key isEqualToString:@"DATE"] || [key isEqualToString:@"SENTDATE"]) {
      sort_att = mailimap_sort_key_new_date(!sortDescriptor.ascending);
    } else if ([key isEqualToString:@"FROM"]) {
      sort_att = mailimap_sort_key_new_from(!sortDescriptor.ascending);
    } else if ([key isEqualToString:@"SIZE"]) {
      sort_att = mailimap_sort_key_new_size(!sortDescriptor.ascending);
    } else if ([key isEqualToString:@"SUBJECT"]) {
      sort_att = mailimap_sort_key_new_subject(!sortDescriptor.ascending);
    } else if ([key isEqualToString:@"TO"]) {
      sort_att = mailimap_sort_key_new_to(!sortDescriptor.ascending);
    }
    
    if (sort_att) {
      mailimap_sort_key_multiple_add(sort_key, sort_att);
    }
  }
  
  return sort_key;
}


#pragma mark - Class methods

+ (CTSearchKeyTransformer *)defaultTransformer {
  static CTSearchKeyTransformer *defaultTransformer;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    defaultTransformer = [[CTSearchKeyTransformer alloc] init];
  });
  
  return defaultTransformer;
}

@end
