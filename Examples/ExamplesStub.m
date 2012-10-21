//
//  ExamplesStub.m
//  mocka
//
//  Created by Markus Gasser on 18.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ExamplesCommon.h"


@interface ExamplesStub : SenTestCase
@end

@implementation ExamplesStub {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    SetupExampleErrorHandler();
    
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Stubbing Return Values

- (void)testByDefaultMocksWillReturnNilOrZero {
    // when you have an unstubbed method it will return the "default" value
    // for objects nil, for numbers 0 and for structs a struct with all fields 0
    
    STAssertTrue([mockArray objectAtIndex:0] == nil, @"Default value for object returns should be nil");
    STAssertTrue([mockArray count] == 0, @"Default value for primitive number returns should be 0");
    STAssertTrue(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(0, 0)), @"Default value for struct returns should be a zero-struct");
}

- (void)testSettingCustomObjectReturnValue {
    // you can set a custom return value for objects
    
    whenCalling [mockArray objectAtIndex:0] thenDo returnValue(@"Hello World");
    
    STAssertEqualObjects([mockArray objectAtIndex:0], @"Hello World", @"Wrong return value");
}

- (void)testSettingCustomPrimitiveNumberReturnValue {
    // you can set a custom return value for primitive numbers
    
    whenCalling [mockArray count] thenDo returnValue(10);

    STAssertEquals([mockArray count], (NSUInteger)10, @"Wrong return value");
}

- (void)testSettingCustomStructReturnValue {
    // you can also set a custom return value for structs
    
    whenCalling [mockString rangeOfString:@"Foo"] thenDo returnStruct(NSMakeRange(10, 20));
    
    STAssertTrue(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(10, 20)), @"Wrong return value");
}


#pragma mark - Stubbing Exceptions

- (void)testThrowingPreconfiguredExceptionFromMockedMethod {
    // you can throw a preconfigured exception in a stubbed method
    
    NSException *preconfiguredException = [NSException exceptionWithName:NSRangeException reason:@"Index 1 out of bounds" userInfo:nil];
    whenCalling [mockArray objectAtIndex:1] thenDo throwException(preconfiguredException);
    
    @try {
        [mockArray objectAtIndex:1];
        STFail(@"Should have thrown");
    } @catch (id exception) {
        STAssertEqualObjects(exception, preconfiguredException, @"Wrong exception was thrown");
    }
}

- (void)testThrowingCreatedExceptionFromMockedMethod {
    // you can throw also a new exception in a stubbed method
    
    whenCalling [mockArray objectAtIndex:1] thenDo throwNewException(NSRangeException, @"Index 1 out of bounds", nil);
    
    STAssertThrowsSpecificNamed([mockArray objectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
}


#pragma mark - Calling Arbitrary Code From Stubs

- (void)testCallingBlockFromStubbedMethod {
    // you can provide a block which gets the NSInvocation passed which you can manipulate at will
    
    whenCalling [mockArray objectAtIndex:11] thenDo performBlock(^(NSInvocation *inv) {
        NSNumber *returnValue = @([inv unsignedIntegerArgumentAtEffectiveIndex:0]);
        [inv setReturnValue:&returnValue];
    });
    
    STAssertEqualObjects([mockArray objectAtIndex:11], @11, @"Wrong return value generated");
}


#pragma mark - Stubbing Multiple Calls And Actions

- (void)testStubbingMultipleCallsWithTheSameActionsBracketVariant {
    // you can have multiple calls stub the same action by putting them in brackets after when calling
    
    whenCalling {
        [mockArray objectAtIndex:1];
        [mockArray removeObjectAtIndex:1];
    } thenDo throwNewException(NSRangeException, @"Index out of bounds", nil);
    
    STAssertThrowsSpecificNamed([mockArray objectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
    STAssertThrowsSpecificNamed([mockArray removeObjectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
}

- (void)testStubbingMultipleCallsWithTheSameActionsOrCallingVariant {
    // you can have multiple calls stub the same action by combining them using orCalling
    
    whenCalling [mockArray objectAtIndex:1] orCalling [mockArray removeObjectAtIndex:1]
    thenDo throwNewException(NSRangeException, @"Index out of bounds", nil);
    
    STAssertThrowsSpecificNamed([mockArray objectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
    STAssertThrowsSpecificNamed([mockArray removeObjectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
}

- (void)testStubbingMultipleActionsForTheSameCallBracketVariant {
    // you can also have multiple actions on the same call by putting them in brackets after thenDo
    
    __block BOOL executed = NO;
    whenCalling [mockArray count] thenDo {
        performBlock(^(NSInvocation *inv) {
            // do something useful here
            executed = YES;
        });
        returnValue(10);
    }
    
    NSUInteger result = [mockArray count];
    STAssertEquals(result, (NSUInteger)10, @"Wrong result returned");
    STAssertTrue(executed, @"Block was not executed");
}

- (void)testStubbingMultipleActionsForTheSameCallAndDoVariant {
    // you can also have multiple actions on the same call by separating them using andDo
    
    __block BOOL executed = NO;
    whenCalling [mockArray count] thenDo returnValue(10) andDo performBlock(^(NSInvocation *inv) {
        // do something useful here
        executed = YES;
    });
    
    NSUInteger result = [mockArray count];
    STAssertEquals(result, (NSUInteger)10, @"Wrong result returned");
    STAssertTrue(executed, @"Block was not executed");
}

- (void)testThatCombinationIsAlsoPossible {
    // of course multiple actions can be applied to multiple stubs
    
    __block NSUInteger executionCount = 0;
    whenCalling {
        [mockArray objectAtIndex:0];
        [mockArray objectAtIndexedSubscript:0];
    } thenDo {
        performBlock(^(NSInvocation *inv) {
            executionCount++;
        });
        returnValue(@"Hello World");
    }
    
    id value1 = [mockArray objectAtIndex:0];
    STAssertEqualObjects(value1, @"Hello World", @"Wrong return value");
    STAssertEquals(executionCount, (NSUInteger)1, @"Wrong execution count");
    
    id value2 = [mockArray objectAtIndexedSubscript:0];
    STAssertEqualObjects(value2, @"Hello World", @"Wrong return value");
    STAssertEquals(executionCount, (NSUInteger)2, @"Wrong execution count");
}


#pragma mark - Using Argument Matchers When Stubbing

- (void)testYouCanUseArgumentMatchersWhenStubbing {
    // instead of specifiying an exact value in whenCalling you can also use argument matchers
    
    
    __block id addedObject = nil;
    whenCalling [mockArray addObject:anyObject()] thenDo performBlock(^(NSInvocation *inv) {
        addedObject = [inv objectArgumentAtEffectiveIndex:0];
    });
    
    [mockArray addObject:@"Hello World"];
    
    STAssertEqualObjects(addedObject, @"Hello World", @"Wrong object added");
}

- (void)testYouCanUseArgumentMatchersAlsoForPrimitiveArguments {
    // matchers are also available for primitive arguments
    
    whenCalling [mockArray objectAtIndex:anyInt()] thenDo performBlock(^(NSInvocation *inv) {
        NSUInteger index = [inv integerArgumentAtEffectiveIndex:0];
        [inv setObjectReturnValue:@(index)];
    });
    
    STAssertEqualObjects([mockArray objectAtIndex:10], @10, @"Wrong return value");
}

- (void)testYouCanMixArgumentsAndMatchersForObjects {
    // for object arguments you can just mix normal arguments and matchers
    
    __block NSArray *insertedObjects = nil;
    __block NSIndexSet *insertedIndexes = nil;
    whenCalling [mockArray insertObjects:@[ @"foo" ] atIndexes:anyObject()] thenDo performBlock(^(NSInvocation *inv) {
        insertedObjects = [inv objectArgumentAtEffectiveIndex:0];
        insertedIndexes = [inv objectArgumentAtEffectiveIndex:1];
    });
    
    [mockArray insertObjects:@[ @"foo" ] atIndexes:[NSIndexSet indexSetWithIndex:3]];
    
    STAssertEqualObjects(insertedObjects, (@[ @"foo" ]), @"Wrong inserted objects");
    STAssertEqualObjects(insertedIndexes, [NSIndexSet indexSetWithIndex:3], @"Wrong inserted indexes");
}

- (void)testYouCanNotMixArgumentsAndMatchersForPrimitives {
    // for primitive arguments you must either use argument matchers only or no matchers at all
    
    whenCalling [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20] thenDo performBlock(nil);             // ok
    whenCalling [mockArray exchangeObjectAtIndex:anyInt() withObjectAtIndex:anyInt()] thenDo performBlock(nil); // ok
    ThisWillFail({
        whenCalling [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:anyInt()] thenDo performBlock(nil);   // not ok
    });
}


#pragma mark - Setting Out Parameters

- (void)testYouCanSetAnOutParameterInStubbing {
    // you can set out-parameters using setOutParameterAtIndex(idx, value);
    
    NSError *testError = [NSError errorWithDomain:@"TestDomain" code:1 userInfo:nil];
    whenCalling [mockString writeToFile:anyObject() atomically:anyBool() encoding:anyInt() error:anyObjectPointer()] thenDo {
        setOutParameterAtIndex(3, testError);
        returnValue(NO);
    }
    
    NSError *reportedError = nil;
    [mockString writeToFile:@"/foo/bar" atomically:YES encoding:NSUTF8StringEncoding error:&reportedError];
    STAssertEqualObjects(reportedError, testError, @"Error was not set");
}

- (void)testPassingNULLForOutParameterHasNoEffect {
    // passing NULL as the out parameter will not cause any trouble
    
    NSError *testError = [NSError errorWithDomain:@"TestDomain" code:1 userInfo:nil];
    whenCalling [mockString writeToFile:anyObject() atomically:anyBool() encoding:anyInt() error:anyObjectPointer()] thenDo {
        setOutParameterAtIndex(3, testError);
        returnValue(NO);
    }
    
    STAssertNoThrow([mockString writeToFile:@"/foo/bar" atomically:YES encoding:NSUTF8StringEncoding error:NULL], @"Should not have failed");
}


#pragma mark - Given When Then Style Stubbing

- (void)testCanAlsoUseGivenCallToAsKeyword {
    // if you prefer stubbing using a given... syntax you can use givenCallTo instead of whenCalling
    // for multiple stubbings you can use orCallTo instead of orCalling
    
    givenCallTo [mockArray count] thenDo returnValue(10);
    
    STAssertEquals([mockArray count], (NSUInteger)10, @"Wrong return value");
}

@end
