//
//  ExamplesArgumentMatchersTest.m
//  mocka
//
//  Created by Markus Gasser on 16.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"
#import "HCBlockMatcher.h"


@interface ExamplesArgumentMatchers : XCTestCase
@end

@implementation ExamplesArgumentMatchers {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Built-in object argument matchers

- (void)testYouCanUseObjectArgumentMatchersInVerify {
    // instead of specifiying an exact value in verify you can also use argument matchers
    
    [mockArray addObject:@"Hello World"];
    match ([mockArray addObject:any(id)]);
}

- (void)testYouCanUseArgumentMatchersWhenStubbing {
    // instead of specifiying an exact value in whenCalling you can also use argument matchers
    
    __block id addedObject = nil;
    stub ([mockArray addObject:any(id)]) with (id object) {
        addedObject = object;
    };
    
    [mockArray addObject:@"Hello World"];
    
    expect(addedObject).to.equal(@"Hello World");
}

- (void)testYouCanMixArgumentsAndMatchersForObjects {
    // for object arguments you can just mix normal arguments and matchers
    
    [mockArray insertObjects:@[ @"foo" ] atIndexes:[NSIndexSet indexSetWithIndex:3]];
    match ([mockArray insertObjects:@[ @"foo" ] atIndexes:any(id)]);
}


#pragma mark - Built-in primitive argument matchers

- (void)testYouCanUseArgumentMatchersForPrimitiveArgumentsInVerify {
    // matchers are also available for primitive arguments
    
    [mockArray objectAtIndex:10];
    match ([mockArray objectAtIndex:any(NSUInteger)]);
}

- (void)testYouCanUseArgumentMatchersForPrimitiveArgumentsWhenStubbing {
    // matchers are also available for primitive arguments
    
    stub ([mockArray objectAtIndex:any(NSUInteger)]) with (NSUInteger index) {
        return @(index);
    };
    
    expect([mockArray objectAtIndex:10]).to.equal(@10);
}

- (void)testYouCanNotMixArgumentsAndMatchersForPrimitives {
    // for primitive arguments you must either use argument matchers only or no matchers at all
    
    [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20];
    [mockArray exchangeObjectAtIndex:30 withObjectAtIndex:40];
    [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:60];
    
    match ([mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20]);                           // ok
    match ([mockArray exchangeObjectAtIndex:any(NSUInteger) withObjectAtIndex:any(NSUInteger)]); // ok
    ThisWillFail({
        match ([mockArray exchangeObjectAtIndex:50 withObjectAtIndex:any(NSUInteger)]);          // not ok
    });
}


#pragma mark - Built-in struct argument matchers

- (void)testYouCanUseArgumentMatchersForStructArgumentsInVerify {
    // matchers are also available for struct arguments
    
    [mockArray subarrayWithRange:NSMakeRange(0, 10)];
    match ([mockArray subarrayWithRange:any(NSRange)]);
}

- (void)testYouCanUseArgumentMatchersForStructArgumentsWhenStubbing {
    // matchers are also available for struct arguments
    
    stub ([mockArray subarrayWithRange:any(NSRange)]) with (NSRange range) {
        return @[ @(range.location), @(range.length) ];
    };
    
    expect([mockArray subarrayWithRange:NSMakeRange(0, 10)]).to.equal(@[ @0, @10 ]);
}


#pragma mark - Exact Matchers

- (void)testThatYouCanUseIntArgToSpecifyAnExactIntArg {
    // since you need to specify either all args as matchers or none for primitives,
    // there is a special matcher that allows you to match the exact argument
    
    [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20];
    [mockArray exchangeObjectAtIndex:30 withObjectAtIndex:40];
    [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:60];
    
    match ([mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20]);                           // ok
    match ([mockArray exchangeObjectAtIndex:any(NSUInteger) withObjectAtIndex:any(NSUInteger)]); // ok
    match ([mockArray exchangeObjectAtIndex:arg(50) withObjectAtIndex:any(NSUInteger)]);      // also ok
}

- (void)testExactStructArgumentMatcherSyntax {
    [mockArray subarrayWithRange:NSMakeRange(10, 20)];
    [mockArray subarrayWithRange:NSMakeRange(30, 40)];
    
    match ([mockArray subarrayWithRange:arg(NSMakeRange(10, 20))]);
    ThisWillFail({
        match ([mockArray subarrayWithRange:arg(NSMakeRange(40, 50))]);
    });
}


#pragma mark - Hamcrest Matchers

- (void)testYouCanUseHamcrestMatchersForObjectsInVerify {
    // for object args you can use hamcrest matchers just like this
    
    [mockArray addObject:@"Hello World"];
    
    match ([mockArray addObject:[HCBlockMatcher matcherWithBlock:^BOOL(id candidate) {
        return [candidate hasPrefix:@"Hello"];
    }]]);
}

- (void)testYouCanUseHamcrestMatchersForPrimitivesInVerify {
    // for primitive args you can use hamcrest matchers by wrapping them in an appropriate <type>ArgThat()
    
    [mockArray objectAtIndex:10];
    
    match ([mockArray objectAtIndex:intArgThat([HCBlockMatcher matcherWithBlock:^BOOL(id candidate) {
        return [candidate isEqual:@10];
    }])]);
}

@end
