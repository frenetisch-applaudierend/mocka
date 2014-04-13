//
//  ExamplesVerify.m
//  mocka
//
//  Created by Markus Gasser on 18.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"
#import "AsyncService.h"


@interface ExamplesVerify : XCTestCase
@end

@implementation ExamplesVerify {
    NSMutableArray *mockArray;
}

#pragma mark - Setup

- (void)setUp
{
    // we'll use this object in the examples
    mockArray = mock([NSMutableArray class]);
}


#pragma mark - Nesting Verification Groups

- (void)testVerificationGroupsCanBeNested
{
    // verification groups can be nested
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeLastObject];
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:@"One"]);
        match ([mockArray addObject:@"Two"]);
        
        matchAnyOf {
            match ([mockArray removeObjectAtIndex:1]);
            match ([mockArray removeLastObject]);
        };
        
        match ([mockArray addObject:@"Three"]);
    };
}


#pragma mark - Verify with Timeout

- (void)testYouCanWaitForAsyncCalls
{
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
    }];
    
    // normal verify would fail, since the callback was not called yet at this point
    // therefore use timeout with verify
    match ([mockArray removeAllObjects]) withTimeout(0.1);
}

- (void)testVerifyFailsAfterTheTimeoutExpires
{
    // call some async service
    [[AsyncService sharedService] waitForTimeInterval:0.1 thenCallBlock:^{
        [mockArray removeAllObjects];
    }];
    
    // the timeout will expire before the async taks is executed, so this fails
    ThisWillFail({
        match ([mockArray removeAllObjects]) withTimeout(0.05);
    });
}

- (void)testTimeoutWorksAlsoWithOtherModes
{
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
        [mockArray removeAllObjects];
    }];
    
    // you can also combine the timeout with verification modes like exactly(...)
    match ([mockArray removeAllObjects]) exactly(2 times) withTimeout(0.2);
}

- (void)testTimeoutWorksDifferentWithNever
{
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
    }];
    
    match ([mockArray removeAllObjects]) never; // this does not fail, because the call is delayed
    
    // when using withTimeout(...) together with verify never then the semantics change a bit
    // in this case the call will wait the whole timeout before checking that no call was made
    ThisWillFail({ // because the call is made after 0.2s and we check after 0.5s
        match ([mockArray removeAllObjects]) never withTimeout(0.5);
    });
}

- (void)testTimeoutAlsoWorksWithInOrder
{
    // do some non-async calls
    [mockArray addObject:@1];
    [mockArray addObject:@2];
    
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
    }];
    
    // normal verify would fail, since the callback was not called yet at this point
    // therefore use timeout with verify
    matchInOrder {
        match ([mockArray addObject:@1]);
        match ([mockArray addObject:@2]);
        match ([mockArray removeAllObjects]) withTimeout(0.5);
    };
}

@end
