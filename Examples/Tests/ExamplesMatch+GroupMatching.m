//
//  ExamplesMatch+GroupMatching.m
//  Examples
//
//  Created by Markus Gasser on 13.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesMatch_GroupMatching : ExampleTestCase @end
@implementation ExamplesMatch_GroupMatching {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Matching Calls in Order

- (void)testYouCanCheckThatCertainCallsWereMadeInOrder
{
    // using matchInOrder you can check that a certain flow of methods is called one after another
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    
    ThisWillFail({
        matchInOrder {
            match ([mockArray addObject:@"One"]);   // "One" was first, OK
            match ([mockArray addObject:@"Three"]); // "Three" is after "One", OK
            match ([mockArray addObject:@"Two"]);   // <-- EVIL, out of order!
        };
    });
}

- (void)testMatchInOrderIgnoresInterleavingCalls
{
    // when matching in order then...
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Unverified"];      // ...this call is ignored...
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Also unverified"]; // ...and also this one
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:@"One"]);
        match ([mockArray addObject:@"Two"]);
        match ([mockArray addObject:@"Three"]);
    };
}

- (void)testMatchInOrderWorksWithModifiers
{
    // three add calls, then remove all => OK
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    [mockArray removeAllObjects];
    
    matchInOrder {
        match ([mockArray addObject:any(id)]) exactly(3 times);
        match ([mockArray removeAllObjects]);
    };
    
    
    // three add calls with one interleaved remove all => not OK
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    ThisWillFail({
        matchInOrder {
            match ([mockArray addObject:any(id)]) exactly(3 times);
            match ([mockArray removeAllObjects]);
        };
    });
}


#pragma mark - Matching Either Call of a Group

- (void)testYouCanMatchOneCallFromGroup
{
    [mockArray objectAtIndex:0]; // could also use [mockArray firstObject] or mockArray[0] here and it would still succeed
    
    // succeeds when any of the following calls matches
    matchAnyOf {
        match (mockArray[0]);
        match ([mockArray objectAtIndex:0]);
        match ([mockArray firstObject]);
    };
}


#pragma mark - Nesting Groups

- (void)testYouCanAlsoNestGroups
{
    // if need be you can also nest matcher groups
    // just don't overdo it...
    
    
    [mockArray addObject:@10];
    [mockArray addObject:@20];
    
    // would also have worked:
    //  [mockArray addObject:@"Foo"];
    //  [mockArray addObject:@"Bar"];
    
    matchAnyOf {
        matchInOrder {
            match ([mockArray addObject:@10]);
            match ([mockArray addObject:@20]);
        };
        matchInOrder {
            match ([mockArray addObject:@"Foo"]);
            match ([mockArray addObject:@"Bar"]);
        };
    };
}

@end
