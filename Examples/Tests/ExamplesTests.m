//
//  ExamplesTests.m
//  ExamplesTests
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Mocka/Mocka.h>


@interface ExamplesTests : XCTestCase

@end

@implementation ExamplesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSArray *mockArray = mockForClass(NSArray);
    
    [mockArray objectAtIndex:0];
    
    match ([mockArray objectAtIndex:0]);
}

@end
