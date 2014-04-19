//
//  IntegrationTests+StubbingBase.m
//  Integration Tests
//
//  Created by Markus Gasser on 14.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "IntegrationTests.h"


#pragma mark - Common

@interface IntegrationTests_Common (StubbingBase) @end
@implementation IntegrationTests_Common (StubbingBase)

#pragma mark - Simple Stubbing

- (void)testThatStubbedMethodsReturnSpecifiedValue
{
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        return @"Hello World";
    };
    
    id result = [self.testObject objectMethodCallWithoutParameters];
    
    expect(result).to.equal(@"Hello World");
}

- (void)testThatMultipleMethodsCanBeStubbedAtOnce
{
    TestObject *object1 = [self newTestObjectForClass:[TestObject class]];
    TestObject *object2 = [self newTestObjectForClass:[TestObject class]];
    
    stub ({
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    }) with {
        return @10;
    };
    
    expect([object1 objectMethodCallWithoutParameters]).to.equal(@10);
    expect([object2 objectMethodCallWithoutParameters]).to.equal(@10);
}

- (void)testThatOneMethodCanBeStubbedMultipleTimesAndAllStubsAreExecutedInOrder
{
    NSMutableArray *calls = [NSMutableArray array];
    
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        [calls addObject:@"First Call"];
        return @"First Result";
    };
    
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        [calls addObject:@"Second Call"];
        return @"Second Result";
    };
    
    id returnValue = [self.testObject objectMethodCallWithoutParameters];
    
    expect(calls).to.equal((@[ @"First Call", @"Second Call"]));
    expect(returnValue).to.equal(@"Second Result");
}

@end


#pragma mark - Mock Objects Only

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


#pragma mark - Spies Only

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
