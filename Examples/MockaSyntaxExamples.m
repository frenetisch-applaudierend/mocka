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


#pragma mark - How about some stubbing?

- (void)testStubbingSyntaxSingleLine {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // returnValue() takes objects, primitives or pointer types, use returnStruct() for struct types performBlock() allows you to execute arbitrary code. 
    whenCalling [array count]; thenDo performBlock(^(NSInvocation *inv) { NSLog(@"%@", [self description]); }); andDo returnValue(10);
    
    // note that the semicolons (;) between the calls/actions are not necessary but they will help with syntax completion in Xcode
    whenCalling [array objectAtIndex:1] thenDo throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    whenCalling [array objectAtIndex:1] thenDo throwNewException(NSRangeException, @"Index out of bounds", nil); // both lines are equivalent
    
    // then
    STAssertEquals((int)[array count], (int)10, @"[array count] stub does not work");
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
}

- (void)testStubbingSyntaxCompound {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // you can take multiple calls together when stubbing like this
    whenCalling [array objectAtIndex:0]; orCalling [array objectAtIndex:2]; thenDo returnValue(@"Foobar");
    
    // alternatively, placing more than one call in a whenCalling { ... } applies the actions also to all of those calls
    whenCalling {
        [array objectAtIndex:1];
        [array removeObjectAtIndex:1];
    }
    thenDo performBlock(^(NSInvocation *inv) { NSLog(@"%@", [self description]); });
    andDo throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    
    // then
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
    STAssertThrowsSpecificNamed([array removeObjectAtIndex:1], NSException, NSRangeException, @"[array removeObjectAtIndex:1] stub does not work");
}


#pragma mark - Argument matchers

- (void)testArgumentMatchersForStubbing {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    whenCalling [array objectAtIndexedSubscript:anyInt()] thenDo returnValue(@"Foo");
    
    // then
    STAssertEqualObjects(array[0], @"Foo", @"anyInt() did not stub index 0");
    STAssertEqualObjects(array[NSNotFound], @"Foo", @"anyInt() did not stub index NSNotFound");
    STAssertEqualObjects(array[1234], @"Foo", @"anyInt() did not stub index 1234");
}

- (void)testArgumentMatchersMustBeUsedForAllPrimitivesInCall {
    // Due to technical limitations, non-object arguments must either be ALL matchers or NO matchers
    // you cannot mix matchers and non-matcher arguments
    
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array exchangeObjectAtIndex:10 withObjectAtIndex:20];
    [array exchangeObjectAtIndex:10 withObjectAtIndex:20];
    [array exchangeObjectAtIndex:10 withObjectAtIndex:20];
    
    // then
    verify [array exchangeObjectAtIndex:10 withObjectAtIndex:20];                 // OK, no matchers used
    verify [array exchangeObjectAtIndex:anyInt() withObjectAtIndex:anyInt()];     // OK, all arguments are matchers
    ThisWillFail({
        verify [array exchangeObjectAtIndex:anyInt() withObjectAtIndex:20];       // ERROR, mix of arguments and matchers
    });
    verify [array exchangeObjectAtIndex:anyInt() withObjectAtIndex:matchInt(20)]; // Use match<Type>(x) to match exact arguments
}

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

- (void)testVerifyPopsInvocationsFromStack {
    // Invocations are pushed on a stack while executing, and popped from the stack during verfiy
    
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"Foobar"];
    [array addObject:@"Foobar"];
    
    // then
    
    // normal verification does not care if there are more calls than verified (it's in effect an atLeast(1))
    // it will fail if there are more verifys than calls though
    verify [array addObject:@"Foobar"]; // as long as there are pushed invocations succeed
    verify [array addObject:@"Foobar"]; // each verification pops the first matching invocation
    ThisWillFail({
        verify [array addObject:@"Foobar"]; // verify will fail if no matching invocation is on the stack
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


#pragma mark - Making sure interaction(s) never happened on mock

- (void)testVerifyNoInteractionsOn {
    // given
    NSMutableArray *arrayOne = mock([NSMutableArray class]);
    NSMutableArray *arrayTwo = mock([NSMutableArray class]);
    NSMutableArray *arrayThree = mock([NSMutableArray class]);
    
    // when
    [arrayThree removeAllObjects];
    
    // then
    verify noInteractionsOn(arrayOne);
    verify noInteractionsOn(arrayTwo);
    ThisWillFail({
        verify noInteractionsOn(arrayThree);
    });
}

- (void)testVerifyNoMoreInteractionsOn {
    // given
    NSMutableArray *arrayOne = mock([NSMutableArray class]);
    NSMutableArray *arrayTwo = mock([NSMutableArray class]);
    
    // when
    [arrayOne addObject:@"Foo"];
    [arrayTwo addObject:@"Foo"];
    [arrayTwo removeAllObjects];
    
    // then
    verify [arrayOne addObject:@"Foo"];
    verify [arrayTwo addObject:@"Foo"];
    verify noMoreInteractionsOn(arrayOne);
    ThisWillFail({
        verify noMoreInteractionsOn(arrayTwo);
    });
}

@end
