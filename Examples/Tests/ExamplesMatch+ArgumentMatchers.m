//
//  ExamplesMatch+ArgumentMatchers.m
//  Examples
//
//  Created by Markus Gasser on 12.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesMatch_ArgumentMatchers : ExampleTestCase @end
@implementation ExamplesMatch_ArgumentMatchers {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
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
    // when you match a method that has object arguments it will match on equal arguments
    //  * isEqual: is used to compare for objects
    
    
    // matches if using the same argument
    [mockArray addObject:@"Hello World"];
    
    match ([mockArray addObject:@"Hello World"]);
    
    
    // but not if the wrong argument is passed
    [mockArray addObject:@"Goodbye World"];
    
    ThisWillFail({
        match ([mockArray addObject:@"Hello World"]);
    });
}

- (void)testDefaultMatchingWorksTheSameForPrimitivesLikeStructs
{
    // when you match a method that has primitive arguments it will match on same arguments
    //  * -[NSNumber isEqual:] is used for scalars
    //  * -[NSValue isEqual:] is used for other primitive types
    
    
    // matches if using the same argument
    [mockArray subarrayWithRange:NSMakeRange(0, 10)];
    
    match ([mockArray subarrayWithRange:NSMakeRange(0, 10)]);
    
    // but not if the wrong argument is passed
    [mockArray subarrayWithRange:NSMakeRange(10, 20)];
    
    ThisWillFail({
        match ([mockArray subarrayWithRange:NSMakeRange(0, 10)]);
    });
}


#pragma mark - Matching Arguments Using Argument Matchers

- (void)testYouCanUseArgumentMatchersToControlHowArgumentsMatch
{
    // if you pass argument matchers, the matcher is used to check passed arguments
    
    // e.g. the any(T) matcher will accept any argument of the given type T
    [mockArray addObject:@"Hello World"];
    
    match ([mockArray addObject:any(id)]);
    
    // also nil arguments match
    [mockArray addObject:nil];
    
    match ([mockArray addObject:any(id)]);
}

- (void)testYouCanUseArgumentMatchersAlsoForPrimitiveTypes
{
    // argument matchers also work for primitive types
    
    [mockArray removeObjectAtIndex:0];
    match ([mockArray removeObjectAtIndex:any(NSUInteger)]);
    
    [mockArray removeObjectAtIndex:NSUIntegerMax];
    match ([mockArray removeObjectAtIndex:any(NSUInteger)]);
}

- (void)testYouCanUseArgumentMatchersEvenForStructs
{
    // matching struct arguments is supported too
    
    [mockArray subarrayWithRange:NSMakeRange(0, 10)];
    match ([mockArray subarrayWithRange:any(NSRange)]);
    
    [mockArray subarrayWithRange:NSMakeRange(0, 0)];
    match ([mockArray subarrayWithRange:any(NSRange)]);
}

@end
