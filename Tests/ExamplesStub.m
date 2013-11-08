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
    
    expect([mockArray objectAtIndex:0]).to.equal(nil);
    expect([mockArray count]).to.equal(0);
    expect(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(0, 0))).to.beTruthy();
}

- (void)testSettingCustomObjectReturnValue {
    // you can set a custom return value for objects
    
    stubCall ([mockArray objectAtIndex:0]) with {
        return @"Hello World";
    };
    
    expect([mockArray objectAtIndex:0]).to.equal(@"Hello World");
}

- (void)testSettingCustomPrimitiveNumberReturnValue {
    // you can set a custom return value for primitive numbers
    
    stubCall ([mockArray count]) with {
        return 10;
    };

    expect([mockArray count]).to.equal(10);
}

- (void)testSettingCustomStructReturnValue {
    // you can also set a custom return value for structs
    
    stubCall ([mockString rangeOfString:@"Foo"]) with {
        return NSMakeRange(10, 20);
    };
    
    expect(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(10, 20))).to.beTruthy();
}


#pragma mark - Accessing Method Arguments from Stubs

- (void)testMethodArgumentsArePassedToBlockIfRequested {
    // if the stub block takes parameters they are taken from the stubbed invocation
    
    stubCall ([mockArray objectAtIndex:anyInt()]) with (NSUInteger index) {
        return @(index);
    };
    
    expect([mockArray objectAtIndex:0]).to.equal(@0);
    expect([mockArray objectAtIndex:1]).to.equal(@1);
    expect([mockArray objectAtIndex:99]).to.equal(@99);
}

- (void)testMethodArgumentsArePassedToBlockIfRequestedIncludingSelfAndCmd {
    // if you also include self and _cmd, those parameters are passed as well to the block
    // NOTE: Either both self and _cmd must be there or none. You cannot choose to only have self or _cmd passed.
    stubCall ([mockArray objectAtIndex:anyInt()]) with (NSArray *self, SEL _cmd, NSUInteger index) {
        return self;
    };
    
    expect([mockArray objectAtIndex:0]).to.equal(mockArray);
}


#pragma mark - Executing Arbitrary Code

- (void)testThrowingCreatedExceptionFromStubbedMethod {
    // you can throw an exception in a stubbed method
    
    stubCall ([mockArray objectAtIndex:1]) with {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil];
    };
    
    expect(^{ [mockArray objectAtIndex:1]; }).to.raise(NSRangeException);
}

- (void)testSettingOutParametersFromStubbedMethod {
    // you can set out parameters passed by reference
    
    stubCall ([mockArray getObjects:anyObjectPointer(__unsafe_unretained) range:anyStruct(NSRange)])
    with (id __unsafe_unretained objects[], NSRange range) {
        objects[0] = @"Hello";
        objects[1] = @"World";
    };
    
    id __unsafe_unretained objects[2];
    [mockArray getObjects:objects range:NSMakeRange(0, 2)];
    
    id object0 = objects[0]; id object1 = objects[1];
    expect(object0).to.equal(@"Hello");
    expect(object1).to.equal(@"World");
}


#pragma mark - Stubbing Multiple Calls And Actions

- (void)testStubbingMultipleCallsWithTheSameActionsBracketVariant {
    // you can have multiple calls stub the same action by putting them in brackets after when calling
    
    stubCalls ({
        [mockArray objectAtIndex:1];
        [mockArray removeObjectAtIndex:1];
    }) with {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil];
    };
    
    expect(^{ [mockArray objectAtIndex:1]; }).to.raise(NSRangeException);
    expect(^{ [mockArray removeObjectAtIndex:1]; }).to.raise(NSRangeException);
}


#pragma mark - Stubbing on matching arguments

- (void)testStubbingWillMatchOnEqualArguments {
    // when you stub a method that has arguments it will match equal arguments (isEqual: is used to compare)
    
    __block BOOL actionWasCalled = NO;
    stubCall ([mockArray addObject:@"Hello World"]) with {
        actionWasCalled = YES;
    };
    
    [mockArray addObject:@"Hello World"];
    
    expect(actionWasCalled).to.beTruthy();
}

- (void)testStubbingWillFailForUnequalArguments {
    // in contrast to above, if the arguments are not equal stubbing will not consider it a match
    
    __block BOOL actionWasCalled = NO;
    stubCall ([mockArray addObject:@"Hello World"]) with {
        actionWasCalled = YES;
    };
    
    [mockArray addObject:@"Goodbye World"];
    
    expect(actionWasCalled).to.beFalsy();
}

- (void)testStubbingWillMatchStructArguments {
    // matching struct arguments is supported too
    
    stubCall ([mockArray subarrayWithRange:NSMakeRange(10, 20)]) with {
        return @[ @"Matches" ];
    };
    
    expect([mockArray subarrayWithRange:NSMakeRange(10, 20)]).to.equal(@[ @"Matches"] );
    expect([mockArray subarrayWithRange:NSMakeRange(20, 10)]).to.beNil();
}


#pragma mark - Stubbing and Verifying in Relation

- (void)testStubbingDoesNotQualifyForVerify {
    // when you stub a method this method is not called, so it's not considered for verify
    
    stubCall ([mockArray objectAtIndex:0]) with {
        return nil;
    };
    
    ThisWillFail({
        verify ([mockArray objectAtIndex:0]);
    });
}

- (void)testStubbingIsNotCalledOnVerify {
    // when you verify a stubbed method, the stub action must not be performed
    stubCall ([mockArray objectAtIndex:0]) with {
        XCTFail(@"Should not be invoked");
        return nil;
    };
    
    verify (never [mockArray objectAtIndex:0]);
}

@end
