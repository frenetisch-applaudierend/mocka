//
//  RGMockInvocationStubber.h
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMockStub;
@protocol RGMockStubAction;


@interface RGMockInvocationStubber : NSObject

#pragma mark - Creating and Updating Stubs

- (void)recordStubInvocation:(NSInvocation *)invocation withNonObjectArgumentMatchers:(NSArray *)matchers;
- (void)addActionToLastStub:(id<RGMockStubAction>)action;


#pragma mark - Applying Stub Actions

@property (nonatomic, readonly) NSArray *recordedStubs;

- (BOOL)hasStubsForInvocation:(NSInvocation *)invocation;
- (void)applyActionsToStubsForInvocation:(NSInvocation *)invocation;

@end
