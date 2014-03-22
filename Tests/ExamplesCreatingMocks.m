//
//  ExamplesCreatingMocks.m
//  mocka
//
//  Created by Markus Gasser on 17.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "Mocka.h"
#import "MCKMockObject.h"
#import "ExamplesCommon.h"


@interface ExamplesCreatingMocks : XCTestCase
@end

@implementation ExamplesCreatingMocks

#pragma mark - Creating Mocks For Classes

- (void)testCreatingMockForClass {
    // to create a mock for a given class, pass the Class to the mock(...) function
    id mockForClass = mock([NSArray class]);
    
    XCTAssertEqualObjects([mockForClass mck_mockedEntites], (@[ [NSArray class] ]), @"Wrong entities mocked");
}

- (void)testCreatingMockForClassShorthand {
    // you can use the shorthand form to create a mock for a class
    // note that you don't need to to wrap the class name in [... class]
    id mockForClass = mockForClass(NSArray);
    
    XCTAssertEqualObjects([mockForClass mck_mockedEntites], (@[ [NSArray class] ]), @"Wrong entities mocked");
}


#pragma mark - Creating Mocks For Protocols

- (void)testCreatingMockForSingleProtocol {
    // to create a mock for a given protocol, pass the @protocol(...) to the mock(...) function
    id mockForProtocol = mock(@protocol(NSCoding));
    
    XCTAssertEqualObjects([mockForProtocol mck_mockedEntites], (@[ @protocol(NSCoding) ]), @"Wrong entities mocked");
}

- (void)testCreatingMockForSingleProtocolShorthand {
    // you can use the shorthand form to create a mock for a protocol
    // note that you don't need to to wrap the protocol name in @protocol(...)
    id mockForProtocol = mockForProtocol(NSCoding);
    
    XCTAssertEqualObjects([mockForProtocol mck_mockedEntites], (@[ @protocol(NSCoding) ]), @"Wrong entities mocked");
}

- (void)testCreatingMockForMultipleProtocols {
    // you're not restricted to a single protocol
    id mockForProtocols = mock(@protocol(NSCoding), @protocol(NSCopying));
    
    XCTAssertEqualObjects([mockForProtocols mck_mockedEntites], (@[ @protocol(NSCoding), @protocol(NSCopying) ]), @"Wrong entities mocked");
}


#pragma mark - Creating Mocks For Class And Protocol

- (void)testCreatingMockForClassAndProtocol {
    // it's possible to create mocks which mock a class and a number of protocols
    id mockForClassAndProtocols = mock([TestObject class], @protocol(NSCoding), @protocol(NSCopying));
    
    XCTAssertEqualObjects([mockForClassAndProtocols mck_mockedEntites], (@[ [TestObject class], @protocol(NSCoding), @protocol(NSCopying) ]),
                         @"Wrong entities mocked");
}


#pragma mark - Creating Spies

- (void)testCreatingSpy {
    // to create a spy you need an existing object
    // spy(...) converts your object to a spy and returns it
    TestObject *object = [[TestObject alloc] init];
    TestObject *spyObject = spy(object);
    
    XCTAssertTrue((object == spyObject), @"Should be the same object");
}


#pragma mark - Things That Won't Work

- (void)testCreatingAnEmptyMockIsNotPossible {
    // it's not legal to create an empty mock and in fact
    // it won't even compile (which is why the code is commented out)
    
    /*
     
     id emptyMock = mock(); // <= error
     
     */
}

- (void)testCreatingMockForMultipleClassesIsNotPossible {
    // it's not legal to create a mock for multiple classes
    ThisWillFail({
        id mockForMultipleClasses = mock([TestObject class], [NSArray class]);
        IgnoreUnused(mockForMultipleClasses);
    });
}

- (void)testCreatingMockForNilIsNotPossible {
    // you may not pass nil as an argument to mock(...)
    // doesn't compile if you pass nil literally
    
    /* Both of those will give you a compilation error
     
     id nilMock = mock(Nil);
     id nilMock = mock([TestObject class], @protocol(NSCoding), Nil, @protocol(NSCopying));
     
     */
    
    // if you hide it in a variable it will compile, but throw an exception at runtime
    ThisWillFail({
        id nilValue = Nil;
        id nilMock = mock([TestObject class], @protocol(NSCoding), nilValue, @protocol(NSCopying));
        IgnoreUnused(nilMock);
    });
}

- (void)testCreatingSpyForNilIsNotPossible {
    // you may not pass nil as an argument to spy(...)
    ThisWillFail({
        id nilObject = nil;
        id nilSpy = spy(nilObject);
        IgnoreUnused(nilSpy);
    });
}

@end
