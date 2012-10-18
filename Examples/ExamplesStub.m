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

@end
