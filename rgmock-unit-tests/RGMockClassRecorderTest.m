//
//  RGClassMockObjectTest.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockClassRecorder.h"
#import "MockTestObject.h"


@interface RGMockClassRecorderTest : SenTestCase
@end


@implementation RGMockClassRecorderTest

- (void)testThatClassMockRecordsMethodCalls {
    // given
    MockTestObject *mock = [RGMockClassRecorder mockRecorderForClass:[MockTestObject class]];
    
    // when
    [mock simpleMethodCall];
    
    // then
    NSArray *recordedInvocations = [(RGMockClassRecorder *)mock mock_recordedInvocations];
    STAssertEquals([recordedInvocations count], (NSUInteger)1, @"Wrong recorded invocation count");
    
    NSInvocation *invocation = [recordedInvocations lastObject];
    STAssertEquals([invocation selector], @selector(simpleMethodCall), @"Wrong invocation recorded");
    STAssertEquals([invocation target], mock, @"Wrong invocation recorded");
}

@end
