//
//  MCKRegressionTest.m
//  mocka
//
//  Created by Markus Gasser on 12/24/12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Mocka/Mocka.h>
#import "ExamplesCommon.h"


@interface MCKRegressionTest : XCTestCase
@end


@implementation MCKRegressionTest {
    NSMutableArray *mockArray;
}

#pragma mark - Setup

- (void)setUp {
    mockArray = mockForClass(NSMutableArray);
}


#pragma mark - Test Cases

- (void)testThatVerifyNoMoreInteractionsSwitchesToRecordingMode {
    // https://bitbucket.org/teamrg_gam/rgmock/issue/8/
    // noMoreInteractions() leaves context in verification state
    
    // when
    verify noMoreInteractionsOn(mockArray);
    
    // then
    AssertDoesNotFail({
        [mockArray removeAllObjects];
    });
}

- (void)testThatNeverDoesNotScrewUpInOrderVerification {
    // https://bitbucket.org/teamrg_gam/mocka/issue/29/
    // When verifying inOrder a "never" verification will screw up the following verification
    
    // when
    [mockArray removeAllObjects];
    [mockArray addObject:@"Foo"];
    
    // then
    AssertDoesNotFail({
        verify inOrder {
            never [mockArray objectAtIndex:anyInt()];
            [mockArray removeAllObjects];
            [mockArray addObject:@"Foo"];
        };
    });
}

@end
