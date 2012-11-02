//
//  EditableInvocationRecorder.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "CannedInvocationCollection.h"
#import "MCKInvocationMatcher.h"


@implementation CannedInvocationCollection

- (id)initWithCannedResult:(NSIndexSet *)indexSet {
    if ((self = [super initWithInvocationMatcher:[[MCKInvocationMatcher alloc] init]])) {
        _cannedResult = [indexSet copy];
    }
    return self;
}

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)argMatchers {
    if (self.cannedResult != nil) {
        return self.cannedResult;
    } else {
        return [super invocationsMatchingPrototype:prototype withPrimitiveArgumentMatchers:argMatchers];
    }
}

@end
