//
//  ExamplesStub+ArgumentMatchers.m
//  Examples
//
//  Created by Markus Gasser on 10.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesStub_ArgumentMatchers : ExampleTestCase @end
@implementation ExamplesStub_ArgumentMatchers {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
    __block BOOL actionWasCalled;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Default Matching

- (void)testByDefaultArgumentsAreMatchedByEquality
{
    // when you stub a method that has object arguments it will match equal arguments
    //  * isEqual: is used to compare for objects
    
    stub ([mockArray addObject:@"Hello World"]) with {
        actionWasCalled = YES;
    };
    
    // call it with the correct argument and the action is executed
    actionWasCalled = NO;
    [mockArray addObject:@"Hello World"];
    
    expect(actionWasCalled).to.beTruthy();
    
    
    // but not if the wrong argument is passed
    actionWasCalled = NO;
    [mockArray addObject:@"Goodbye World"];
    
    expect(actionWasCalled).to.beFalsy();
}

- (void)testDefaultMatchingWorksTheSameForPrimitivesLikeStructs
{
    // when you stub a method that has primitive arguments it will match same arguments
    //  * -[NSNumber isEqual:] is used for scalars
    //  * -[NSValue isEqual:] is used for other primitive types
    
    stub ([mockArray subarrayWithRange:NSMakeRange(0, 10)]) with {
        actionWasCalled = YES;
        return nil;
    };
    
    // call it with the correct argument and the action is executed
    actionWasCalled = NO;
    [mockArray subarrayWithRange:NSMakeRange(0, 10)];
    
    expect(actionWasCalled).to.beTruthy();
    
    
    // but not if the wrong argument is passed
    actionWasCalled = NO;
    [mockArray subarrayWithRange:NSMakeRange(10, 20)];
    
    expect(actionWasCalled).to.beFalsy();
}


#pragma mark - Matching Arguments Using Argument Matchers

- (void)testYouCanUseArgumentMatchersToControlHowArgumentsMatch
{
    // if you pass argument matchers, the matcher is used to check passed arguments
    
    // e.g. the any(T) matcher will accept any argument of the given type T
    stub ([mockArray addObject:any(id)]) with {
        actionWasCalled = YES;
    };
    
    // any value will match
    actionWasCalled = NO;
    [mockArray addObject:@"Some Object"];
    
    expect(actionWasCalled).to.beTruthy();
    
    // also nil matches
    actionWasCalled = NO;
    [mockArray addObject:nil];
    
    expect(actionWasCalled).to.beTruthy();
}

- (void)testYouCanUseArgumentMatchersAlsoForPrimitiveTypes
{
    // argument matchers also work for primitive types
    
    stub ([mockArray removeObjectAtIndex:any(NSUInteger)]) with {
        actionWasCalled = YES;
    };
    
    // any value will match
    actionWasCalled = NO;
    [mockArray removeObjectAtIndex:0];
    
    expect(actionWasCalled).to.beTruthy();
    
    actionWasCalled = NO;
    [mockArray removeObjectAtIndex:NSUIntegerMax];
    
    expect(actionWasCalled).to.beTruthy();
}

- (void)testYouCanUseArgumentMatchersEvenForStructs
{
    // matching struct arguments is supported too
    
    stub ([mockArray subarrayWithRange:any(NSRange)]) with {
        actionWasCalled = YES;
        return nil;
    };
    
    // any value will match
    actionWasCalled = NO;
    [mockArray subarrayWithRange:NSMakeRange(0, 10)];
    
    expect(actionWasCalled).to.beTruthy();
    
    actionWasCalled = NO;
    [mockArray subarrayWithRange:NSMakeRange(0, 0)];
    
    expect(actionWasCalled).to.beTruthy();
}

@end
