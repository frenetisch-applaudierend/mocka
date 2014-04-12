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


#pragma mark - Verify An Exact Number Of Invocations

- (void)testUseOnceToSpecifyExactlyOneInvocation
{
    // by default verify will succeed if one *or more* calls which match are made
    // verify once will only succeed if there was *exactly* one call whitch matches
    // same as verify exactly(1 times)
    
    [mockArray count];
    [mockArray objectAtIndex:0];
    [mockArray objectAtIndex:1];
    
    match ([mockArray count]) exactly(once);
    ThisWillFail({
        match ([mockArray objectAtIndex:any(NSUInteger)]) exactly(once);
    });
}

- (void)testUseExactlyToSpecifyAnExactNumberOfInvocations
{
    // using verify exactly(X) you can test that exactly X matching calls were made
    
    [mockArray objectAtIndex:0];
    [mockArray objectAtIndex:1];
    [mockArray count];
    
    match ([mockArray objectAtIndex:any(NSUInteger)]) exactly(2 times);
    ThisWillFail({
        match ([mockArray count]) exactly(2 times);
    });
}

- (void)testUseNeverToSpecifyNoMatchingCallsWereMade
{
    // using verify never you can test that no matching call was made
    // same as verify exactly(0)
    
    [mockArray objectAtIndex:0];
    
    match ([mockArray count]) never;
    ThisWillFail({
        match ([mockArray objectAtIndex:any(NSUInteger)]) never;
    });
}


#pragma mark - Verify That No Actions Were Executed

- (void)testVerifyingNoInteractionsFailsIfAnyUnverifiedCallsWereMade
{
    // using matchNoInteractionsOn() or matchNoMoreInteractionsOn() you can
    // check if no unverified invocations were done on the specified mock
    
    matchNoInteractionsOn(mockArray); // no interactions made, all is fine
    
    [mockArray count];
    ThisWillFail({
        matchNoInteractionsOn(mockArray); // [mockArray count] is an unverified interaction
    });
}

- (void)testVerifyingNoInteractionsDoesNotFailForVerifiedInteractions
{
    // verified interactions are not checked with noInteractionsOn() / noMoreInteractionsOn()
    // note: the two variants are synonyms, but noMoreInteractionsOn() reads better when
    //       previous verify calls were made
    
    [mockArray count];
    
    match ([mockArray count]);
    matchNoMoreInteractionsOn(mockArray); // [mockArray count] was verified
}


#pragma mark - Ordered Verify

- (void)testThatVerifyingInOrderFailsIfCallIsMadeOutOfOrder
{
    // by verifying in order you can check that a certain flow of methods is called one after another
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    
    ThisWillFail({
        matchInOrder {
            match ([mockArray addObject:@"One"]);
            match ([mockArray addObject:@"Three"]);
            match ([mockArray addObject:@"Two"]);   // <-- EVIL, out of order!
        };
    });
}

- (void)testThatVerifyingInOrderIgnoresUnverifiedCalls
{
    // if you simply verify in order then 
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Unverified"];      // this is ignored
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Also unverified"]; // also this
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:@"One"]);
        match ([mockArray addObject:@"Two"]);
        match ([mockArray addObject:@"Three"]);
    };
}

- (void)testCanUseExactlyInOrderedVerify
{
    // you can use exactly() as usual in ordered verify
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    [mockArray removeAllObjects];
    
    matchInOrder {
        match ([mockArray addObject:any(NSString*)]) exactly(3 times);
        match ([mockArray removeAllObjects]);
    };
}

- (void)testLeadingUnverifiedMethodCallsAreIgnoredWithExactly
{
    // also with exactly, leading method calls are just ignored
    
    [mockArray count];
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    [mockArray removeAllObjects];
    
    matchInOrder {
        match ([mockArray addObject:any(id)]) exactly(3 times);
        match ([mockArray removeAllObjects]);
    };
}

- (void)testInterleavedUnverifiedMethodCallsAreIgnoredWithExactly
{
    // also with exactly, interleaving method calls are just ignored
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:any(id)]) exactly(3 times);
    };
}

- (void)testOrderedVerifyFailsIfExactlyFails
{
    // exactly must also match exactly n objects in ordered verify
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    
    ThisWillFail({
        matchInOrder {
            match ([mockArray addObject:any(id)]) exactly(3 times);
            match ([mockArray removeAllObjects]);
        };
    });
}

- (void)testOrderedVerifyFailsForInterleavedCallsWhichShouldBeOrderedWithExactly
{
    // if exactly skips calls while verifying, the skipped calls are not evaluated further
    
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

- (void)testSkippedCallsCanLaterStillBeVerified
{
    // if exactly skips calls while verifying, the skipped calls can be verified outside of the matchInOrder
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:any(id)]) exactly(3 times);
    };
    match ([mockArray removeAllObjects]);
}

- (void)testSkippedCallsCanLaterStillBeVerifiedOrdered
{
    // skipped calls can even be verified ordered later
    
    [mockArray addObject:@"One"];
    [mockArray count];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:any(id)]) exactly(3 times);
    };
    
    matchInOrder {
        match ([mockArray count]);
        match ([mockArray removeAllObjects]);
    };
}

- (void)testOrderingIsAlsoEnforcedWhenTestingSkippedCalls
{
    // skipped calls can even be verified ordered later
    
    [mockArray addObject:@"One"];
    [mockArray count];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    matchInOrder {
        match ([mockArray addObject:any(id)]) exactly(3 times);
    };
    
    ThisWillFail({
        matchInOrder {
            match ([mockArray removeAllObjects]);
            match ([mockArray count]);
        };
    });
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
