//
//  ExamplesStubBasic.m
//  Examples
//
//  Created by Markus Gasser on 09.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesStubBasic : ExampleTestCase @end
@implementation ExamplesStubBasic {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Default Values

- (void)testByDefaultMocksWillReturnNilOrZero
{
    // when you call an unstubbed method on a mock it will return the "default" value:
    
    // nil for objects
    expect([mockArray objectAtIndex:0]).to.beNil();
    
    // zero for scalars
    expect([mockArray count]).to.equal(0);
    
    // a zeroed struct for structs
    expect(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(0, 0))).to.beTruthy();
}


#pragma mark - Basic Stubbing

- (void)testYouCanStubReturnValues
{
    // return an object
    stub ([mockArray objectAtIndex:0]) with { return @"Hello"; };
    
    // ...or a scalar
    stub ([mockArray count]) with { return 1; };
    
    // ...or even a struct
    stub ([mockString rangeOfString:@"Foo"]) with { return NSMakeRange(0, 3); };
    
    
    expect([mockArray count]).to.equal(1);
    expect([mockArray objectAtIndex:0]).to.equal(@"Hello");
    expect(NSEqualRanges([mockString rangeOfString:@"Foo"], NSMakeRange(0, 3))).to.beTruthy();
}

- (void)testYouCanStubActions
{
    // e.g. set an out variable
    __block BOOL wasCalled = NO; // __block is needed to write the variable
    stub ([mockArray enumerateObjectsUsingBlock:nil]) with {
        wasCalled = YES;
    };
    
    [mockArray enumerateObjectsUsingBlock:nil];
    
    expect(wasCalled).to.beTruthy();
}

- (void)testYouCanThrowExceptions
{
    stub ([mockArray objectAtIndex:1]) with {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Index out of bounds" userInfo:nil];
    };
    
    expect(^{ [mockArray objectAtIndex:1]; }).to.raiseWithReason(NSRangeException, @"Index out of bounds");
}

@end
