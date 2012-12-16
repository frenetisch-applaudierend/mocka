//
//  ExamplesArgumentMatchersTest.m
//  mocka
//
//  Created by Markus Gasser on 16.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ExamplesCommon.h"


@interface ExamplesArgumentMatchers : SenTestCase
@end

@implementation ExamplesArgumentMatchers {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    SetupExampleErrorHandler();
    
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Built-in object matchers basics

- (void)testYouCanUseObjectArgumentMatchersInVerify {
    // instead of specifiying an exact value in verify you can also use argument matchers
    [mockArray addObject:@"Hello World"];
    verify [mockArray addObject:anyObject()];
}

- (void)testYouCanUseArgumentMatchersWhenStubbing {
    // instead of specifiying an exact value in whenCalling you can also use argument matchers
    
    __block id addedObject = nil;
    whenCalling [mockArray addObject:anyObject()] thenDo performBlock(^(NSInvocation *inv) {
        addedObject = [inv objectParameterAtIndex:0];
    });
    
    [mockArray addObject:@"Hello World"];
    
    STAssertEqualObjects(addedObject, @"Hello World", @"Wrong object added");
}

- (void)testYouCanMixArgumentsAndMatchersForObjects {
    // for object arguments you can just mix normal arguments and matchers
    [mockArray insertObjects:@[ @"foo" ] atIndexes:[NSIndexSet indexSetWithIndex:3]];
    verify [mockArray insertObjects:@[ @"foo" ] atIndexes:anyObject()];
}


#pragma mark - Built-in primitive argument matchers basics

- (void)testYouCanUseArgumentMatchersAlsoForPrimitiveArgumentsInVerify {
    // matchers are also available for primitive arguments
    
    [mockArray objectAtIndex:10];
    
    verify [mockArray objectAtIndex:anyInt()];
}

- (void)testYouCanUseArgumentMatchersAlsoForPrimitiveArgumentsWhenStubbing {
    // matchers are also available for primitive arguments
    
    whenCalling [mockArray objectAtIndex:anyInt()] thenDo performBlock(^(NSInvocation *inv) {
        NSUInteger index = [inv unsignedIntegerParameterAtIndex:0];
        [inv setObjectReturnValue:@(index)];
    });
    
    STAssertEqualObjects([mockArray objectAtIndex:10], @10, @"Wrong return value");
}

- (void)testYouCanNotMixArgumentsAndMatchersForPrimitives {
    // for primitive arguments you must either use argument matchers only or no matchers at all
    
    [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20];
    [mockArray exchangeObjectAtIndex:30 withObjectAtIndex:40];
    [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:60];
    
    verify [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20];             // ok
    verify [mockArray exchangeObjectAtIndex:anyInt() withObjectAtIndex:anyInt()]; // ok
    ThisWillFail({
        verify [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:anyInt()];   // not ok
    });
}

@end
