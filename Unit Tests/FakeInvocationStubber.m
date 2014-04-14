//
//  FakeInvocationStubber.m
//  mocka
//
//  Created by Markus Gasser on 5.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "FakeInvocationStubber.h"


@interface FakeInvocationStubber ()

@property (nonatomic, copy) BOOL(^applyObserver)(NSInvocation*);

@end

@implementation FakeInvocationStubber

#pragma mark - Initialization

+ (instancetype)fakeStubber {
    return [[self alloc] init];
}


#pragma mark - Overridden Behavior

- (void)applyStubsForInvocation:(NSInvocation *)invocation {
    if (self.applyObserver == nil || self.applyObserver(invocation)) {
        [super applyStubsForInvocation:invocation];
    }
}


#pragma mark - Observer Blocks

- (void)onApplyStubsForInvocation:(BOOL(^)(NSInvocation *invocation))observer {
    self.applyObserver = observer;
}

@end
