//
//  ExamplesStub.m
//  mocka
//
//  Created by Markus Gasser on 18.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"


@interface ExamplesStub : XCTestCase
@end

@implementation ExamplesStub {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Stubbing Return Values

- (void)testByDefaultMocksWillReturnNilOrZero {
    // when you have an unstubbed method it will return the "default" value
    // for objects nil, for numbers 0 and for structs a struct with all fields 0
    
    XCTAssertTrue([mockArray objectAtIndex:0] == nil, @"Default value for object returns should be nil");
    XCTAssertTrue([mockArray count] == 0, @"Default value for primitive number returns should be 0");
    XCTAssertTrue(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(0, 0)), @"Default value for struct returns should be a zero-struct");
}

- (void)testSettingCustomObjectReturnValue {
    // you can set a custom return value for objects
    
    whenCalling ([mockArray objectAtIndex:0]) thenDo (returnValue(@"Hello World"));
    
    XCTAssertEqualObjects([mockArray objectAtIndex:0], @"Hello World", @"Wrong return value");
}

- (void)testSettingCustomPrimitiveNumberReturnValue {
    // you can set a custom return value for primitive numbers
    
    whenCalling ([mockArray count]) thenDo (returnValue(10));

    XCTAssertEqual([mockArray count], (NSUInteger)10, @"Wrong return value");
}

- (void)testSettingCustomStructReturnValue {
    // you can also set a custom return value for structs
    
    whenCalling ([mockString rangeOfString:@"Foo"]) thenDo (returnStruct(NSMakeRange(10, 20)));
    
    XCTAssertTrue(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(10, 20)), @"Wrong return value");
}


#pragma mark - Stubbing Exceptions

- (void)testThrowingPreconfiguredExceptionFromMockedMethod {
    // you can throw a preconfigured exception in a stubbed method
    
    NSException *stubException = [NSException exceptionWithName:NSRangeException reason:@"Index 1 out of bounds" userInfo:nil];
    whenCalling ([mockArray objectAtIndex:1]) thenDo (throwException(stubException));
    
    @try {
        [mockArray objectAtIndex:1];
        XCTFail(@"Should have thrown");
    } @catch (id exception) {
        XCTAssertEqualObjects(exception, stubException, @"Wrong exception was thrown");
    }
}

- (void)testThrowingCreatedExceptionFromMockedMethod {
    // you can throw also a new exception in a stubbed method
    
    whenCalling ([mockArray objectAtIndex:1]) thenDo (throwNewException(NSRangeException, @"Index 1 out of bounds", nil));
    
    XCTAssertThrowsSpecificNamed([mockArray objectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
}


#pragma mark - Calling Arbitrary Code From Stubs

- (void)testCallingBlockFromStubbedMethod {
    // you can provide a block which gets the NSInvocation passed which you can manipulate at will
    
    whenCalling ([mockArray objectAtIndex:11]) thenDo ({
        performBlock(^(NSInvocation *inv) {
            NSNumber *returnValue = @([inv unsignedIntegerParameterAtIndex:0] + 1);
            [inv setReturnValue:&returnValue];
        });
    });
    
    XCTAssertEqualObjects([mockArray objectAtIndex:11], @12, @"Wrong return value generated");
}


#pragma mark - Stubbing Multiple Calls And Actions

- (void)testStubbingMultipleCallsWithTheSameActionsBracketVariant {
    // you can have multiple calls stub the same action by putting them in brackets after when calling
    
    whenCalling ({
        [mockArray objectAtIndex:1];
        [mockArray removeObjectAtIndex:1];
    }) thenDo ({
        throwNewException(NSRangeException, @"Index out of bounds", nil);
    });
    
    XCTAssertThrowsSpecificNamed([mockArray objectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
    XCTAssertThrowsSpecificNamed([mockArray removeObjectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
}

- (void)testStubbingMultipleCallsWithTheSameActionsOrCallingVariant {
    // you can have multiple calls stub the same action by combining them using orCalling
    
    whenCalling ({
        [mockArray objectAtIndex:1];
        [mockArray removeObjectAtIndex:1];
    }) thenDo ({
        throwNewException(NSRangeException, @"Index out of bounds", nil);
    });
    
    XCTAssertThrowsSpecificNamed([mockArray objectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
    XCTAssertThrowsSpecificNamed([mockArray removeObjectAtIndex:1], NSException, NSRangeException, @"No or wrong exception thrown");
}

- (void)testStubbingMultipleActionsForTheSameCall {
    // you can also have multiple actions on the same call by putting them in brackets after thenDo
    
    __block BOOL executed = NO;
    whenCalling ([mockArray count]) thenDo ({
        performBlock(^(NSInvocation *inv) {
            executed = YES; // do something useful here instead
        });
        returnValue(10);
    });
    
    NSUInteger result = [mockArray count];
    XCTAssertEqual(result, (NSUInteger)10, @"Wrong result returned");
    XCTAssertTrue(executed, @"Block was not executed");
}

- (void)testThatCombinationIsAlsoPossible {
    // of course multiple actions can be applied to multiple stubs
    
    __block NSUInteger executionCount = 0;
    whenCalling ({
        [mockArray objectAtIndex:0];
        [mockArray objectAtIndexedSubscript:0];
    }) thenDo ({
        performBlock(^(NSInvocation *inv) {
            executionCount++;
        });
        returnValue(@"Hello World");
    });
    
    id value1 = [mockArray objectAtIndex:0];
    XCTAssertEqualObjects(value1, @"Hello World", @"Wrong return value");
    XCTAssertEqual(executionCount, (NSUInteger)1, @"Wrong execution count");
    
    id value2 = [mockArray objectAtIndexedSubscript:0];
    XCTAssertEqualObjects(value2, @"Hello World", @"Wrong return value");
    XCTAssertEqual(executionCount, (NSUInteger)2, @"Wrong execution count");
}


#pragma mark - Setting Out Parameters

- (void)testYouCanSetAnOutParameterInStubbing {
    // you can set out-parameters using setOutParameterAtIndex(idx, value);
    
    NSError *testError = [NSError errorWithDomain:@"TestDomain" code:1 userInfo:nil];
    whenCalling ([mockString writeToFile:anyObject() atomically:anyBool() encoding:anyInt() error:anyObjectPointer()]) thenDo ({
        setOutParameterAtIndex(3, testError);
        returnValue(NO);
    });
    
    NSError *reportedError = nil;
    [mockString writeToFile:@"/foo/bar" atomically:YES encoding:NSUTF8StringEncoding error:&reportedError];
    XCTAssertEqualObjects(reportedError, testError, @"Error was not set");
}

- (void)testPassingNULLForOutParameterHasNoEffect {
    // passing NULL as the out parameter will not cause any trouble
    
    NSError *testError = [NSError errorWithDomain:@"TestDomain" code:1 userInfo:nil];
    whenCalling ([mockString writeToFile:anyObject() atomically:anyBool() encoding:anyInt() error:anyObjectPointer()]) thenDo ({
        setOutParameterAtIndex(3, testError);
        returnValue(NO);
    });
    
    XCTAssertNoThrow([mockString writeToFile:@"/foo/bar" atomically:YES encoding:NSUTF8StringEncoding error:NULL],
                     @"Should not have failed");
}


#pragma mark - Stubbing on matching arguments

- (void)testStubbingWillMatchOnEqualObjectArguments {
    // when you stub a method that has arguments it will match equal arguments (isEqual: is used to compare)
    
    __block BOOL actionWasCalled = NO;
    whenCalling ([mockArray addObject:@"Hello World"]) thenDo ({
        performBlock(^(NSInvocation *inv) { actionWasCalled = YES; });
    });
    
    [mockArray addObject:@"Hello World"];
    
    XCTAssertTrue(actionWasCalled, @"Action should have been called");
}

- (void)testStubbingWillFailForUnequalObjectArguments {
    // in contrast to above, if the arguments are not equal stubbing will not consider it a match
    
    __block BOOL actionWasCalled = NO;
    whenCalling ([mockArray addObject:@"Hello World"]) thenDo ({
        performBlock(^(NSInvocation *inv) { actionWasCalled = YES; });
    });
    
    [mockArray addObject:@"Goodbye World"];
    
    XCTAssertFalse(actionWasCalled, @"Action should not have been called");
}

- (void)testStubbingWillMatchOnEqualPrimitiveArguments {
    // when you stub a method that has arguments it will match equal arguments (isEqual: is used to compare)
    
    __block BOOL actionWasCalled = NO;
    whenCalling ([mockArray objectAtIndex:10]) thenDo ({
        performBlock(^(NSInvocation *inv) { actionWasCalled = YES; });
    });
    
    [mockArray objectAtIndex:10];
    
    XCTAssertTrue(actionWasCalled, @"Action should have been called");
}

- (void)testStubbingWillFailForUnequalPrimitiveArguments {
    // in contrast to above, if the arguments are not equal stubbing will not consider it a match
    
    __block BOOL actionWasCalled = NO;
    whenCalling ([mockArray objectAtIndex:10]) thenDo ({
        performBlock(^(NSInvocation *inv) { actionWasCalled = YES; });
    });
    
    [mockArray objectAtIndex:1];
    
    XCTAssertFalse(actionWasCalled, @"Action should not have been called");
}

- (void)testStubbingWillMatchOnEqualStructArguments {
    // when you stub a method that has arguments it will match equal arguments (isEqual: is used to compare)
    
    __block BOOL actionWasCalled = NO;
    whenCalling ([mockArray subarrayWithRange:NSMakeRange(10, 20)]) thenDo ({
        performBlock(^(NSInvocation *inv) { actionWasCalled = YES; });
    });
    
    [mockArray subarrayWithRange:NSMakeRange(10, 20)];
    
    XCTAssertTrue(actionWasCalled, @"Action should have been called");
}

- (void)testStubbingWillFailForUnequalStructArguments {
    // in contrast to above, if the arguments are not equal stubbing will not consider it a match
    
    __block BOOL actionWasCalled = NO;
    whenCalling ([mockArray subarrayWithRange:NSMakeRange(10, 20)]) thenDo ({
        performBlock(^(NSInvocation *inv) { actionWasCalled = YES; });
    });
    
    [mockArray subarrayWithRange:NSMakeRange(10, 0)];
    
    XCTAssertFalse(actionWasCalled, @"Action should not have been called");
}


#pragma mark - Stubbing and Verifying in Relation

- (void)testStubbingDoesNotQualifyForVerify {
    // when you stub a method this method is not called, so it's not considered for verify
    
    whenCalling ([mockArray objectAtIndex:0]) thenDo (returnValue(10));
    
    ThisWillFail({
        verify ([mockArray objectAtIndex:0]);
    });
}

- (void)testStubbingIsNotCalledOnVerify {
    // when you verify a stubbed method, the stub action must not be performed
    whenCalling ([mockArray objectAtIndex:0]) thenDo ({
        performBlock(^(NSInvocation *inv) { XCTFail(@"Should not be invoked"); });
    });
    
    verify ({ never [mockArray objectAtIndex:0]; });
}

@end
