//
//  ExamplesCreating+Mocks.m
//  Examples
//
//  Created by Markus Gasser on 07.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"
#import "TestObject.h"


@interface ExamplesCreating_Mocks : ExampleTestCase @end
@implementation ExamplesCreating_Mocks

#pragma mark - Creating Mocks For Classes

- (void)testCreatingMockForClass
{
    // to create a mock for a given class, pass the Class to the mock(...) macro
    
    id mockForClass = mock([NSArray class]);
    
    expect(mockForClass).to.beKindOf([NSArray class]);
}

- (void)testCreatingMockForClassShorthand
{
    // you can use the shorthand form to create a mock for a class
    // note that you don't need to to wrap the class name in [... class]
    
    id mockForClass = mockForClass(NSArray);
    
    expect(mockForClass).to.beKindOf([NSArray class]);
}


#pragma mark - Creating Mocks For Protocols

- (void)testCreatingMockForSingleProtocol
{
    // to create a mock for a given protocol, pass the @protocol(...) to the mock(...) macro
    
    id mockForProtocol = mock(@protocol(NSCoding));
    
    expect(mockForProtocol).to.conformTo(@protocol(NSCoding));
}

- (void)testCreatingMockForSingleProtocolShorthand
{
    // you can use the shorthand form to create a mock for a protocol
    // note that you don't need to to wrap the protocol name in @protocol(...)
    
    id mockForProtocol = mockForProtocol(NSCoding);
    
    expect(mockForProtocol).to.conformTo(@protocol(NSCoding));
}

- (void)testCreatingMockForMultipleProtocols
{
    // you're not restricted to a single protocol
    
    id mockForProtocols = mock(@protocol(NSCoding), @protocol(NSCopying));
    
    expect(mockForProtocols).to.conformTo(@protocol(NSCoding));
    expect(mockForProtocols).to.conformTo(@protocol(NSCopying));
}


#pragma mark - Creating Mocks For Class And Protocol

- (void)testCreatingMockForClassAndProtocol
{
    // it's possible to create mocks which mock a class and a number of protocols
    
    id mockForClassAndProtocols = mock([TestObject class], @protocol(NSCoding), @protocol(NSCopying));
    
    expect(mockForClassAndProtocols).to.beKindOf([TestObject class]);
    expect(mockForClassAndProtocols).to.conformTo(@protocol(NSCoding));
    expect(mockForClassAndProtocols).to.conformTo(@protocol(NSCopying));
}


#pragma mark - Things That Won't Work

- (void)testCreatingAnEmptyMockIsNotPossible
{
    // it's not legal to create an empty mock and in fact
    // it won't even compile (which is why the code is commented out)
    
    ThisWillNotCompile({
        (void)mock(); // <= error
    });
}

- (void)testCreatingMockForNilIsNotPossible
{
    // you may not pass nil as an argument to mock(...)
    // it won't even compile if you pass the literal nil
    
    // both of these will give you a compilation error
    ThisWillNotCompile({
        (void)mock(Nil);
    });
    ThisWillNotCompile({
        (void)mock([TestObject class], @protocol(NSCoding), Nil, @protocol(NSCopying));
    });
    
    // if you hide it in a variable it will compile, but throw an exception at runtime
    ThisWillFail({
        id nilValue = Nil;
        mock([TestObject class], @protocol(NSCoding), nilValue, @protocol(NSCopying));
    });
}

@end
