//
//  POSQLite3BackendTest.m
//  rgmock
//
//  Created by Markus Gasser on 11.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


static id mock(id something) { return nil; }

static BOOL returnObject(id obj) { return YES; }
static BOOL returnInt(int value) { return YES; }
static BOOL throwException(id ex) { return YES; }
static BOOL callSelectorOnTarget(id target, SEL selector) { return YES; }

static int anyIntArg() { return 0; }
static NSString* anyStringArg() { return nil; }


#define stub if (YES)
#define andDo ; if (YES)

#define verify if (YES)
#define verifyInOrder if (YES)
#define verifyInStrictOrder if (YES)

#define verifyNoInteractionsOn(...) ((void)[NSArray arrayWithObjects:__VA_ARGS__, nil])
#define verifyNoMoreInteractionsOn(...) ((void)[NSArray arrayWithObjects:__VA_ARGS__, nil])

#define exactlyOnce() if (YES)
#define exactly(num) if (YES)
#define never() if (YES)


@interface RGMockSyntaxExamples : SenTestCase
@end


@implementation RGMockSyntaxExamples


#pragma mark - Let's verify some behaviour!

- (void)testVerifySyntaxSingleLine {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"Foo"];
    
    // then
    verify [array addObject:@"Foo"];
}

- (void)testVerifySyntaxCompound {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"Foo"];
    [array removeAllObjects];
    
    // then
    verify {
        [array addObject:@"Foo"];
        [array removeAllObjects];
    }
}

- (void)testVerifyNormalContextDoesNotHaveMeaning {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"Foo"];
    [array addObject:@"Bar"];
    
    [array addObject:@"Foo"];
    [array addObject:@"Bar"];
    
    // then
    verify {
        [array addObject:@"Foo"];
        [array addObject:@"Bar"];
    }
    
    verify [array addObject:@"Foo"];
    verify [array addObject:@"Bar"];
    
    // both verification styles above have the same effects
}

#pragma mark - How about some stubbing?

- (void)testStubbingSyntaxSingleLine {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    stub [array count]
    andDo callSelectorOnTarget(self, @selector(description)) && returnInt(10); // concatenate actions with &&
    
    // also possible to do a complete one-liner
    stub [array objectAtIndex:1] andDo throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    
    // then
    STAssertEquals((int)[array count], (int)10, @"[array count] stub does not work");
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
}

- (void)testStubbingSyntaxCompound {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    stub {
        [array objectAtIndex:1];
        [array removeObjectAtIndex:1];
    } andDo {
        callSelectorOnTarget(self, @selector(description));
        throwException([NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil]);
    } // more than one call in a stub { ... } applies the andDo { ... } actions to all of the calls

    // then
    STAssertThrowsSpecificNamed([array objectAtIndex:1], NSException, NSRangeException, @"[array objectAtIndex:1] stub does not work");
    STAssertThrowsSpecificNamed([array removeObjectAtIndex:1], NSException, NSRangeException, @"[array removeObjectAtIndex:1] stub does not work");
}


#pragma mark - Argument matchers

- (void)testArgumentMatchersForStubbing {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    stub [array objectAtIndex:anyIntArg()] andDo returnObject(@"Foo");
    
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
    verify {
        [array objectAtIndex:anyIntArg()];
        [array removeObjectAtIndex:anyIntArg()];
        [array replaceObjectAtIndex:anyIntArg() withObject:anyStringArg()];
    }
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
    verify {
        // Exactly once is the same as exactly(1)
        exactlyOnce() [array addObject:@"exactly once"];
        exactly(1) [array addObject:@"exactly once alternative"];
        
        // Multiple times
        exactly(2) [array addObject:@"exactly twice"];
        
        // Same as above, see also -testVerifyDifferenceBetweenExactlyAndNormalVerify
        [array addObject:@"exactly twice alternative"];
        [array addObject:@"exactly twice alternative"];
        never() [array addObject:@"exactly twice alternative"];
        
        // Never means exactly this... ensure a call was not made
        never() [array addObject:@"No such call"];
    }
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
    verify {
        // normal verification does not care if there are more calls (it's in effect an atLeast(1))
        STAssertNoThrow([array addObject:@"normal verify once"], @"Behavior of normal verify is flawed");
        
        @try {
            // exactly does care if there are more calls and will fail if there are any
            exactly(1) [array addObject:@"exactly once"];
            STFail(@"Behavior of exactly() verify is flawed");
        }
        @catch (id anything) {}
    }
}

- (void)testVerifyPopsInvocationsFromStack {
    // Invocations are pushed on a stack while executing, and popped from the stack during verfiy
    
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    // when
    [array addObject:@"Foobar"];
    [array addObject:@"Foobar"];
    
    // then
    verify {
        // normal verification does not care if there are more calls (it's in effect an atLeast(1))
        STAssertNoThrow([array addObject:@"Foobar"], @"Push/pop of invocations is flawed"); // as long as there are pushed invocations succeed
        STAssertNoThrow([array addObject:@"Foobar"], @"Push/pop of invocations is flawed"); // each verification pops the first matching invocation
        STAssertThrows([array addObject:@"Foobar"], @"Push/pop of invocations is flawed");  // verify will fail if no matching invocation is on the stack
    }
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
    verifyInOrder {
        [array addObject:@"First"];  // ok - in sequence
        [array addObject:@"Second"]; // ok - in sequence
        //[array addObject:@"Out of sequence but not tested"]; not verified
        [array addObject:@"Fourth"]; // ok - in sequence relative to previous verified call
        STAssertThrows([array addObject:@"Third"], @"verifyInOrder allows out of sequence calls"); // not ok - not in sequence relative to previous verified call
    }
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
    verifyInStrictOrder {
        [array addObject:@"First"];  // ok - in sequence
        [array addObject:@"Second"]; // ok - in sequence
        //[array addObject:@"Out of sequence but not tested"]; not verified
        STAssertThrows([array addObject:@"Third"], @"verifyInStrictOrder allows out of sequence calls"); // not ok - not in sequence relative to all recorded calls
        STAssertThrows([array addObject:@"Fourth"], @"verifyInStrictOrder allows out of sequence calls"); // not ok - not in sequence relative to all recorded calls
    }
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
    verifyNoInteractionsOn(arrayOne, arrayTwo);
    STAssertThrows(verifyNoInteractionsOn(arrayThree), @"verifyNoInteractionsOn() is flawed");
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
    verify {
        [arrayOne addObject:@"Foo"];
        [arrayTwo addObject:@"Foo"];
    }
    verifyNoMoreInteractionsOn(arrayOne);
    STAssertThrows(verifyNoMoreInteractionsOn(arrayTwo), @"verifyNoMoreInteractionsOn() is flawed");
}

@end
