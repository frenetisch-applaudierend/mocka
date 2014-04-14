//
//  ExamplesMatch+Async.m
//  Examples
//
//  Created by Markus Gasser on 14.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesMatch_Async : ExampleTestCase @end
@implementation ExamplesMatch_Async {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Waiting for Async Calls

- (void)testYouCanWaitForCallsToHappen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mockArray addObject:@"Foo"];
    });
    
    ThisWillFail({
        match ([mockArray addObject:@"Foo"]); // checking too early, call is not yet made
    });
    
    match ([mockArray addObject:@"Foo"]) withTimeout(0.1); // waiting with timeout gives dispatch_asnyc(...) time to process
}

- (void)testMatchingWillFailAfterTheTimeoutExpires
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mockArray addObject:@"Foo"];
    });
    
    // the timeout will expire before the async taks is executed, so this fails
    ThisWillFail({
        match ([mockArray addObject:@"Foo"]) withTimeout(0.05);
    });
}

- (void)testTimeoutWorksDifferentWithSomeModifiers
{
    // By default, match (...) will try to return as soon as possible from a withTimeout() call.
    // But some modifiers like never and exactly() cause match(...) to await the timeout fully for successful
    // checks. Be aware of this and set the timeout to a minimum value in those cases.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mockArray addObject:@"Foo"];
    });
    
    match ([mockArray addObject:@"Foo"]) exactly(once) withTimeout(0.1); // will always wait for 0.1sec
}


@end
