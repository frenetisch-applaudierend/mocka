//
//  MockaSyntaxExamples.m
//  mocka
//
//  Created by Markus Gasser on 11.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ExamplesCommon.h"


#define inOrder if (YES)
#define inStrictOrder if (YES)
#define matchInt(x) anyInt()


@interface NSObject (MCKSyntaxExamples)
- (void)fooWithBar:(id)bar baz:(float)baz;
@end


@interface MockaSyntaxExamples : SenTestCase
@end


@implementation MockaSyntaxExamples

#pragma mark - Setup

- (void)setUp {
    SetupExampleErrorHandler();
}


#pragma mark - Argument matchers

- (void)testArgumentMatchersForOutParameters {
    // given
    NSFileManager *fileManager = mock([NSFileManager class]);
    
    whenCalling [fileManager createDirectoryAtPath:anyObject() withIntermediateDirectories:anyBool() attributes:anyObject() error:anyObjectPointer()]
    thenDo returnValue(YES);
    
    // Use the stubbed file manager somewhere
}


#pragma mark - Verifying exact number of invocations / at least x / never

- (void)testVerifyExactNumberOfInvocations {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"exactly once"];
    
    [array addObject:@"exactly once alternative"];
    
    [array addObject:@"exactly twice"];
    [array addObject:@"exactly twice"];
    
    [array addObject:@"exactly twice alternative"];
    [array addObject:@"exactly twice alternative"];
    
    // then
    
    // Once is the same as exactly(1)
    verify once [array addObject:@"exactly once"];
    verify exactly(1) [array addObject:@"exactly once alternative"];
    
    // Multiple times
    verify exactly(2) [array addObject:@"exactly twice"];
    
    // Same as above, see also -testVerifyDifferenceBetweenExactlyAndNormalVerify
    verify [array addObject:@"exactly twice alternative"];
    verify [array addObject:@"exactly twice alternative"];
    verify never [array addObject:@"exactly twice alternative"];
    
    // Never means exactly this... ensure a call was not made
    verify never [array addObject:@"No such call"];
}

- (void)testVerifyDifferenceBetweenExactlyAndNormalVerify {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"normal verify once"];
    [array addObject:@"normal verify once"];
    
    [array addObject:@"exactly once"];
    [array addObject:@"exactly once"];
    
    // then
    
    // normal verification does not care if there are more calls (it's in effect an atLeast(1))
    verify [array addObject:@"normal verify once"]; // this won't fail
    
    // exactly() does care if there are more calls and will fail if there are any
    ThisWillFail({
        verify exactly(1) [array addObject:@"exactly once"];
    });
}


#pragma mark - Verification in order

- (void)_TODO_testVerifyInOrderWillFailForOutOfSequenceCallsOnlyOfVerifiedCalls {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"First"];
    [array addObject:@"Second"];
    [array addObject:@"Out of sequence but not tested"];
    [array addObject:@"Third"];
    [array addObject:@"Fourth"];
    
    // then
    inOrder {
        verify [array addObject:@"First"];  // ok - in sequence
        verify [array addObject:@"Second"]; // ok - in sequence
        //[array addObject:@"Out of sequence but not tested"]; not verified
        verify [array addObject:@"Fourth"]; // ok - in sequence relative to previous verified call
        ThisWillFail({
            verify [array addObject:@"Third"]; // not ok - not in sequence relative to previous verified call
        });
    };
}

- (void)_TODO_testVerifyInStrictOrderWillFailForOutOfSequenceCallsOfAnyCalls {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"First"];
    [array addObject:@"Second"];
    [array addObject:@"Out of sequence but not tested"];
    [array addObject:@"Third"];
    [array addObject:@"Fourth"];
    
    // then
    inStrictOrder {
        verify [array addObject:@"First"];  // ok - in sequence
        verify [array addObject:@"Second"]; // ok - in sequence
        //[array addObject:@"Out of sequence but not tested"]; not verified
        ThisWillFail({
            verify [array addObject:@"Third"]; // not ok - not in sequence relative to all recorded calls
        });
        ThisWillFail({
            verify [array addObject:@"Fourth"]; // not ok - not in sequence relative to all recorded calls
        });
    };
}

@end
