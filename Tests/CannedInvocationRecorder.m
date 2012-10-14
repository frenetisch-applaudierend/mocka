//
//  EditableInvocationRecorder.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "CannedInvocationRecorder.h"
#import "RGMockInvocationMatcher.h"


@implementation CannedInvocationRecorder

- (id)initWithCannedResult:(NSIndexSet *)indexSet {
    if ((self = [super initWithInvocationMatcher:[[RGMockInvocationMatcher alloc] init]])) {
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
