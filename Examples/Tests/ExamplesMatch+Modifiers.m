//
//  ExamplesMatch+Modifiers.m
//  Examples
//
//  Created by Markus Gasser on 12.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"


@interface ExamplesMatch_Modifiers : ExampleTestCase @end
@implementation ExamplesMatch_Modifiers {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Test That a Given Number of Calls Were Made

- (void)testExactlyModifierOnMatch
{
    // by appending exactly(...) to match (...) you can specify how often the call should be matched
    
    [mockArray count];
    match ([mockArray count]) exactly(once);
    
    [mockArray addObject:@"Foo"];
    [mockArray addObject:@"Foo"];
    [mockArray addObject:@"Foo"];
    
    match ([mockArray addObject:@"Foo"]) exactly(3 times);
    
    
    // less calls will fail
    [mockArray addObject:@"Bar"];
    
    ThisWillFail({
        match ([mockArray addObject:@"Bar"]) exactly(2 times);
    });
    
    
    // more calls will fail
    [mockArray addObject:@"Baz"];
    [mockArray addObject:@"Baz"];
    [mockArray addObject:@"Baz"];
    
    ThisWillFail({
        match ([mockArray addObject:@"Baz"]) exactly(2 times);
    });
}


#pragma mark - Test That a Call was Never Made

- (void)testNeverModifierOnMatch
{
    // by appening never to match (...) you can specify that a certain call should never have been called
    
    [mockArray addObject:@"Foo"];
    
    match ([mockArray addObject:@"Baz"]) never;     // no such call was made
    
    ThisWillFail({
        match ([mockArray addObject:@"Foo"]) never; // call was made, so this fails
    });
}

- (void)testNoMoreModifierOnMatch
{
    // noMore is equivalent to never, but it reads better when there were previous matching calls
    
    [mockArray addObject:@"Foo"];
    
    match ([mockArray addObject:@"Foo"]);
    match ([mockArray addObject:@"Foo"]) noMore; // you could also use never
}


#pragma mark - Test That No Calls At All Were Made

- (void)testNoInteractionsOnMatch
{
    // to make sure that there were no interactions on a mock use matchNoInteractionsOn(...)
    
    // no calls
    matchNoInteractionsOn(mockArray);
    
    // with any call it fails
    [mockArray count];
    ThisWillFail({
        matchNoInteractionsOn(mockArray);
    });
}

- (void)testNoMoreInteractionsOnMatch
{
    // matchNoMoreInteractionsOn(...) is equivalent to matchNoInteractionsOn(...) but reads better when there were
    // calls made before
    
    [mockArray addObject:@"Foo"];
    
    match ([mockArray addObject:@"Foo"]);
    matchNoMoreInteractionsOn(mockArray); // you could also use matchNoInteractionsOn(...)
}

@end
