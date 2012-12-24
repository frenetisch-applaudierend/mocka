//
//  MCKRegressionTest.m
//  mocka
//
//  Created by Markus Gasser on 12/24/12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ExamplesCommon.h"


@interface MCKRegressionTest : SenTestCase
@end


@implementation MCKRegressionTest {
    NSMutableArray *mockArray;
}

#pragma mark - Setup

- (void)setUp {
    mockArray = mockForClass(NSMutableArray);
}


#pragma mark - Test Cases

- (void)testThatNeverDoesNotScrewUpInOrderVerification {
    // https://bitbucket.org/teamrg_gam/mocka/issue/29/
    
    [mockArray removeAllObjects];
    [mockArray addObject:@"Foo"];
    
    AssertDoesNotFail({
        verify inOrder {
            never [mockArray objectAtIndex:anyInt()];
            [mockArray removeAllObjects];
            [mockArray addObject:@"Foo"];
        };
    });
}



@end
