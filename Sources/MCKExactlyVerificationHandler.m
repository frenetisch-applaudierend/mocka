//
//  MCKExactlyVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExactlyVerificationHandler.h"
#import "MCKInvocationMatcher.h"
#import "MCKInvocationRecorder.h"


@implementation MCKExactlyVerificationHandler {
    NSUInteger _count;
}

#pragma mark - Initialization

+ (id)exactlyHandlerWithCount:(NSUInteger)count {
    return [[self alloc] initWithCount:count];
}

- (id)initWithCount:(NSUInteger)count {
    if ((self = [super init])) {
        _count = count;
    }
    return self;
}


#pragma mark - Matching Invocations

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
            withPrimitiveArgumentMatchers:(NSArray *)matchers
                     inInvocationRecorder:(MCKInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recorder invocationsMatchingPrototype:prototype withPrimitiveArgumentMatchers:matchers];
    
    if (satisified != NULL) {
        *satisified = ([indexes count] == _count);
    }
    
    if ([indexes count] != _count && failureMessage != NULL) {
        NSString *targetDescription = [prototype.target description];
        NSString *selectorDescription = NSStringFromSelector(prototype.selector);
        *failureMessage = [NSString stringWithFormat:@"Expected exactly %ld calls to -[%@ %@] but got %ld",
                           (unsigned long)_count, targetDescription, selectorDescription, (unsigned long)[indexes count]];
    }
    
    return (([indexes count] == _count) ? indexes : [NSIndexSet indexSet]);
}

@end
