//
//  POSQLite3BackendTest.m
//  rgmock
//
//  Created by Markus Gasser on 11.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMock.h"


#define inOrder if (YES)
#define inStrictOrder if (YES)
#define matchObject(x) x

#define ThisWillFail(...) @try { do { __VA_ARGS__ ; } while(0); STFail(@"Should have thrown"); } @catch (id ignore) {}

@interface NSObject (RGMockSyntaxExamples)
- (void)fooWithBar:(id)bar baz:(float)baz;
@end


@interface RGMockSyntaxExamples : SenTestCase
@end


@implementation RGMockSyntaxExamples


#pragma mark - Let's verify some behaviour!

- (void)testVerifySyntax {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"Foo"];
    
    // then
    verify [array addObject:@"Foo"];
}


#pragma mark - How about some stubbing?

- (void)testStubbingSyntaxSingleLine {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    stub [array count];
    soThatItWill performBlock(^(NSInvocation *inv) { NSLog(@"%@", [self description]); });
    andItWill returnValue(10); // returnValue() takes objects, primitives or pointer types, use returnStruct() for struct types
    
    // also possible to do a complete one-liner
    stub [array objectAtIndex:1]; soThatItWill throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    
    // then
    STAssertEquals((int)[array count], (int)10, @"[array count] stub does not work");
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
}

- (void)testStubbingSyntaxCompound {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // more than one call in a stub { ... } applies the actions to all of the stubbed calls
    stub {
        [array objectAtIndex:1];
        [array removeObjectAtIndex:1];
    }
    soThatItWill performBlock(^(NSInvocation *inv) { NSLog(@"%@", [self description]); });
    andItWill throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    
    // then
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
    STAssertThrowsSpecificNamed([array removeObjectAtIndex:1], NSException, NSRangeException, @"[array removeObjectAtIndex:1] stub does not work");
}


#pragma mark - Argument matchers

- (void)testArgumentMatchersForStubbing {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    stub [array objectAtIndexedSubscript:anyInt()]; soThatItWill returnValue(@"Foo");
    
    // then
    STAssertEqualObjects(array[0], @"Foo", @"anyInt() did not stub index 0");
    STAssertEqualObjects(array[NSNotFound], @"Foo", @"anyInt() did not stub index NSNotFound");
    STAssertEqualObjects(array[1234], @"Foo", @"anyInt() did not stub index 1234");
}

- (void)testArgumentMatchersForVerifying {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array objectAtIndex:10];
    [array removeObjectAtIndex:NSNotFound];
    [array replaceObjectAtIndex:1234 withObject:@"New Object"];
    
    // then
    verify [array objectAtIndex:anyInt()];
    verify [array removeObjectAtIndex:anyInt()];
    verify [array replaceObjectAtIndex:anyInt() withObject:anyObject()];
}

- (void)testArgumentMatchersMustBeUsedForWholeInvocation {
    // Due to technical limitations, arguments must either be ALL matchers or NO matchers
    // you cannot mix matchers and non-matcher arguments
    
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array replaceObjectAtIndex:12 withObject:@"Foobar"];
    [array replaceObjectAtIndex:12 withObject:@"Foobar"];
    [array replaceObjectAtIndex:12 withObject:@"Foobar"];
    
    // then
    verify [array replaceObjectAtIndex:12 withObject:@"Foobar"];           // OK, no matchers used
    verify [array replaceObjectAtIndex:anyInt() withObject:anyObject()];   // OK, all arguments are matchers
    ThisWillFail({
        verify [array replaceObjectAtIndex:anyInt() withObject:@"Foobar"]; // ERROR, mix of arguments and matchers
    });
    verify [array replaceObjectAtIndex:anyInt() withObject:matchObject(@"Foobar")]; // Use match<Type>(x) to match exact arguments
}

- (void)testArgumentMatchersForOutParameters {
    // given
    NSFileManager *fileManager = mock([NSFileManager class]);
    
    stub [fileManager createDirectoryAtPath:anyObject() withIntermediateDirectories:anyBool() attributes:anyObject() error:anyObjectPointer()];
    soThatItWill returnValue(YES);
    
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

- (void)testVerifyInOrderWillFailForOutOfSequenceCallsOnlyOfVerifiedCalls {
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

- (void)testVerifyInStrictOrderWillFailForOutOfSequenceCallsOfAnyCalls {
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
