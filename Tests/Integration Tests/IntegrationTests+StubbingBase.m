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
