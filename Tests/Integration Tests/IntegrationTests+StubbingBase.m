//
//  IntegrationTests+StubbingBase.m
//  Integration Tests
//
//  Created by Markus Gasser on 14.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "IntegrationTests.h"


@interface IntegrationTests_Common (StubbingBase) @end
@implementation IntegrationTests_Common (StubbingBase)

#pragma mark - Simple Stubbing

- (void)testThatStubbedMethodsReturnSpecifiedValue
{
    // given
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        return @"Hello World";
    };
    
    // when
    id result = [self.testObject objectMethodCallWithoutParameters];
    
    // then
    expect(result).to.equal(@"Hello World");
}

- (void)testThatMultipleMethodsCanBeStubbedAtOnce
{
    // given
    TestObject *object1 = [self newTestObjectForClass:[TestObject class]];
    TestObject *object2 = [self newTestObjectForClass:[TestObject class]];
    
    // when
    stub ({
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    }) with {
        return @10;
    };
    
    // then
    expect([object1 objectMethodCallWithoutParameters]).to.equal(@10);
    expect([object2 objectMethodCallWithoutParameters]).to.equal(@10);
}

@end


@interface IntegrationTests_MockObjects (StubbingBase) @end
@implementation IntegrationTests_MockObjects (StubbingBase)

- (void)testThatUnstubbedMethodsReturnDefaultValues
{
    expect([self.testObject objectMethodCallWithoutParameters]).to.equal(nil);
    expect([self.testObject intMethodCallWithoutParameters]).to.equal(0);
    expect([self.testObject intPointerMethodCallWithoutParameters]).to.equal(NULL);
    expect(NSEqualRanges(NSMakeRange(0, 0), [self.testObject rangeMethodCallWithoutParameters])).to.beTruthy();
}

@end


@interface IntegrationTests_Spies (StubbingBase) @end
@implementation IntegrationTests_Spies (StubbingBase)

- (void)testThatUnstubbedMethodsReturnOriginalValues
{
    TestObject *reference = [[TestObject alloc] init];
    
    expect([self.testObject objectMethodCallWithoutParameters]).to.equal([reference objectMethodCallWithoutParameters]);
    expect([self.testObject intMethodCallWithoutParameters]).to.equal([reference intMethodCallWithoutParameters]);
    expect([self.testObject intPointerMethodCallWithoutParameters]).to.equal([reference intPointerMethodCallWithoutParameters]);
    expect(NSEqualRanges([self.testObject rangeMethodCallWithoutParameters], [reference rangeMethodCallWithoutParameters])).to.beTruthy();
}

@end
