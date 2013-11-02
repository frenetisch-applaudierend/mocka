//
//  MCKSpyIntegrationTest.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKIntegrationTestBase.h"


@interface MCKSpyIntegrationTest : MCKIntegrationTestBase
@end

@implementation MCKSpyIntegrationTest


#pragma mark - Setup

- (TestObject *)createTestObject {
    return spy([[TestObject alloc] init]);
}

- (CategoriesTestMockedClass *)createCategoriesTestObject {
    return spy([[CategoriesTestMockedClass alloc] init]);
}


#pragma mark - Overridden Test Cases

- (void)testThatUnstubbedMethodsReturnDefaultValues {
    // default for spies is the original value
    
    TestObject *reference = [[TestObject alloc] init];
    
    expect([self.testObject objectMethodCallWithoutParameters]).to.equal([reference objectMethodCallWithoutParameters]);
    expect([self.testObject intMethodCallWithoutParameters]).to.equal([reference intMethodCallWithoutParameters]);
    expect([self.testObject intPointerMethodCallWithoutParameters]).to.equal([reference intPointerMethodCallWithoutParameters]);
    expect(NSEqualRanges([self.testObject rangeMethodCallWithoutParameters],
                         [reference rangeMethodCallWithoutParameters])).to.beTruthy();
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // overridden because the default value for an unstubbed method is not nil
    
    // given
    TestObject *object1 = [self createTestObject];
    TestObject *object2 = [self createTestObject];
    TestObject *object3 = [self createTestObject];
    TestObject *object4 = [self createTestObject];
    TestObject *reference = [[TestObject alloc] init];
    
    __block NSString *marker = nil;
    
    // when
    stubCall ([object1 objectMethodCallWithoutParameters]) with { return @"First Object"; };
    stubCall ([object2 objectMethodCallWithoutParameters]) with { return @"Second Object"; };
    stubCall ([object3 objectMethodCallWithoutParameters]) with {
        marker = @"Third Object";
        return nil;
    };
    
    [object4 objectMethodCallWithoutParameters];
    
    // then
    expect([object1 objectMethodCallWithoutParameters]).to.equal(@"First Object");
    expect(marker).to.beNil();
    
    expect([object2 objectMethodCallWithoutParameters]).to.equal(@"Second Object");
    expect(marker).to.beNil();
    
    expect([object3 objectMethodCallWithoutParameters]).to.beNil();
    expect(marker).to.equal(@"Third Object");
    
    expect([object4 objectMethodCallWithoutParameters]).to.equal([reference objectMethodCallWithoutParameters]);
    expect(marker).to.equal(@"Third Object");
    // non-stubbed call was suddenly stubbed otherwise
}

@end
