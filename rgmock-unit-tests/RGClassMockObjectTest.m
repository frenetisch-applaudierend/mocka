//
//  RGClassMockObjectTest.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGClassMockRecorder.h"
#import "MockTestObject.h"


@interface RGClassMockObjectTest : SenTestCase
@end


@implementation RGClassMockObjectTest

- (void)testThatClassMockRecordsMethodCalls {
    // given
    MockTestObject *mock = [RGClassMockRecorder mockRecorderForClass:[MockTestObject class]];
    
    // when
    [mock simpleMethod];
    
    // then
    NSArray *recordedInvocations = [(RGClassMockRecorder *)mock mock_recordedInvocations];
    STAssertEquals([recordedInvocations count], (NSUInteger)1, @"Wrong recorded invocation count");
    
    NSInvocation *invocation = [recordedInvocations lastObject];
    STAssertEquals([invocation selector], @selector(simpleMethod), @"Wrong invocation recorded");
    STAssertEquals([invocation target], mock, @"Wrong invocation recorded");
}

@end
