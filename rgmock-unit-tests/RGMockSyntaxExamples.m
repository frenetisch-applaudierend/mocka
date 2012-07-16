//
//  POSQLite3BackendTest.m
//  rgmock
//
//  Created by Markus Gasser on 11.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMock.h"


static BOOL throwException(id ex) { return YES; }
static BOOL callTargetWithSelector(id target, SEL selector, ...) { return YES; }

static int anyIntArg() { return 0; }
static NSString* anyStringArg() { return nil; }

#define call(...) throwException(^() { __VA_ARGS__ ; })

#define inOrder if (YES)
#define inStrictOrder if (YES)

static BOOL noInteractionsOn(id mock) {
    return YES;
}
static BOOL noMoreInteractionsOn(id mock) {
    return YES;
}

#define once if (YES)
#define exactly(num) if (YES)
#define never if (YES)

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
    mock(@protocol(NSCoding));
    
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
    whichWill call([self description]);
    andItWill returnValue(@10); // return values are always defined as objects, automatically unboxed for primitive types
    
    // also possible to do a complete one-liner
    stub [array objectAtIndex:1]; whichWill throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    
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
    whichWill call([self fooWithBar:@"Something" baz:2.0f]);
    andItWill throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    
    // then
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
    STAssertThrowsSpecificNamed([array removeObjectAtIndex:1], NSException, NSRangeException, @"[array removeObjectAtIndex:1] stub does not work");
}


#pragma mark - Argument matchers

- (void)testArgumentMatchersForStubbing {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    stub [array objectAtIndex:anyIntArg()]; whichWill returnValue(@"Foo");
    
    // then
    STAssertEqualObjects([array objectAtIndex:0], @"Foo", @"anyIntArg() did not stub index 0");
    STAssertEqualObjects([array objectAtIndex:NSNotFound], @"Foo", @"anyIntArg() did not stub index NSNotFound");
    STAssertEqualObjects([array objectAtIndex:1234], @"Foo", @"anyIntArg() did not stub index 1234");
}

- (void)testArgumentMatchersForVerifying {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array objectAtIndex:10];
    [array removeObjectAtIndex:NSNotFound];
    [array replaceObjectAtIndex:1234 withObject:@"New Object"];
    
    // then
    verify [array objectAtIndex:anyIntArg()];
    verify [array removeObjectAtIndex:anyIntArg()];
    verify [array replaceObjectAtIndex:anyIntArg() withObject:anyStringArg()];
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
