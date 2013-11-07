//
//  FakeInvocationStubber.h
//  mocka
//
//  Created by Markus Gasser on 5.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKInvocationStubber.h"


@interface FakeInvocationStubber : MCKInvocationStubber

#pragma mark - Initialization

+ (instancetype)fakeStubber;


#pragma mark - Observer Blocks

// return YES from observer for default behavior
// if NO is returned, default apply behavior is suppressed
- (void)onApplyStubsForInvocation:(BOOL(^)(NSInvocation *invocation))observer;

@end
