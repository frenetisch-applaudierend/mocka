//
//  MCKMockObjectTest.m
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKMockObject.h"

#import "FakeMockingContext.h"
#import "TestObject.h"
#import "CategoriesTestClasses.h"

#import "MCKAPIMisuse.h"


@protocol SampleProtocol1 <NSObject> @end
@protocol SampleProtocol2 <SampleProtocol1> @end
@protocol SampleProtocol3 <SampleProtocol2> @end

@interface SampleClass1 : NSObject @end
@implementation SampleClass1 @end
@interface SampleClass2 : SampleClass1 @end
@implementation SampleClass2 @end

@interface SampleClass3 : NSObject <SampleProtocol2> @end
@implementation SampleClass3 @end
@interface SampleClass4 : SampleClass3 @end
@implementation SampleClass4 @end

@interface DelegateHolder : NSObject
@property (nonatomic, weak) id delegate;
@end
@implementation DelegateHolder
@end


@interface MCKMockObjectTest : XCTestCase
@end

@implementation MCKMockObjectTest

#pragma mark - Test Initializer

- (void)testThatInitializerFailsForEmptyClassOrProtocolList
{
    NSArray *invalidClassOrProtocolList = @[];
    
    expect(^{
        [MCKMockObject mockWithContext:[FakeMockingContext fakeContext] entities:invalidClassOrProtocolList];
    }).to.raise(MCKAPIMisuseException);
}

- (void)testThatInitializerFailsIfObjectIsPassedWhichIsNotClassOrProtocol
{
    NSArray *invalidClassOrProtocolList = @[ [TestObject class], @protocol(NSCoding), @"Fail here" ];
    
    expect(^{
        [MCKMockObject mockWithContext:[FakeMockingContext fakeContext] entities:invalidClassOrProtocolList];
    }).to.raise(MCKAPIMisuseException);
}

- (void)testThatInitializerFailsIfMultipleClassesArePassed
{
    NSArray *invalidClassOrProtocolList = @[ [TestObject class], [NSObject class] ];
    
    expect(^{
        [MCKMockObject mockWithContext:[FakeMockingContext fakeContext] entities:invalidClassOrProtocolList];
    }).to.raise(MCKAPIMisuseException);
}

- (void)testThatInitializerRegistersItselfWithTheMockingContext
{
    MCKMockingContext *context = MKTMock([MCKMockingContext class]);
    
    id mockObject = [MCKMockObject mockWithContext:context entities:@[ [TestObject class] ]];
    
    [MKTVerify(context) registerMockObject:mockObject];
}

- (void)testThatMockObjectDoesNotHaveStrongReferenceToContext
{
    // given
    __strong MCKMockingContext *strongContext = [[MCKMockingContext alloc] init];
    __weak   MCKMockingContext *weakContext = strongContext;
    __strong id mockObject = [MCKMockObject mockWithContext:strongContext entities:@[ [TestObject class] ]];
    
    // when
    strongContext = nil; // this should be the last strong reference
    
    // then
    expect(weakContext).to.beNil(); // otherwise there must be another strong reference
    mockObject = nil;
}


#pragma mark - Test Forwarding Invocations

- (void)testThatForwardInvocationCallsMockingContextsHandleInvocation
{
    // given
    FakeMockingContext *fakeContext = [FakeMockingContext fakeContext];
    MCKMockObject *mock = [MCKMockObject mockWithContext:(id)fakeContext entities:@[ [NSObject class] ]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    
    // when
    [mock forwardInvocation:invocation];
    
    // then
    XCTAssertEqual([fakeContext.handledInvocations count], (NSUInteger)1, @"Wrong number of handled invocations");
    XCTAssertEqualObjects(fakeContext.handledInvocations[0], invocation, @"Wrong invocation handled");
}


#pragma mark - Test -respondsToSelector:

- (void)testThatRespondsToSelectorReturnsTrueForSelectorOnPassedClass
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ [TestObject class] ]];
    
    // then
    XCTAssertTrue([mock respondsToSelector:@selector(voidMethodCallWithoutParameters)], @"Mock does not respond to instance method of class");
}

- (void)testThatRespondsToSelectorReturnsTrueForSelectorOnPassedProtocol
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ @protocol(NSCoding) ]];
    
    // then
    XCTAssertTrue([mock respondsToSelector:@selector(encodeWithCoder:)], @"Mock does not respond to instance method of class");
}

- (void)testThatRespondsToSelectorReturnsTrueForSelectorsIfBothClassAndProtocolArePassed
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil
                                                                 entities:@[ [TestObject class], @protocol(NSCoding) ]];
    
    // then
    XCTAssertTrue([mock respondsToSelector:@selector(voidMethodCallWithoutParameters)], @"Mock does not respond to instance method of class");
    XCTAssertTrue([mock respondsToSelector:@selector(encodeWithCoder:)], @"Mock does not respond to instance method of class");
}


#pragma mark - Test -isKindOfClass: and -conformsToProtocol:

- (void)testThatMockIsKindOfMockedClass
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ [SampleClass1 class] ]];
    
    // then
    XCTAssertTrue([mock isKindOfClass:[SampleClass1 class]], @"Mock is not a kind of the mocked class");
}

- (void)testThatMockIsKindOfMockedClassSuperclass
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ [SampleClass2 class] ]];
    
    // then
    XCTAssertTrue([mock isKindOfClass:[SampleClass1 class]], @"Mock is not a kind of the inherited mocked class");
}

- (void)testThatMockConformsToMockedProtocols
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ @protocol(SampleProtocol1) ]];
    
    // then
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to mocked protocol");
}

- (void)testThatMockConformsToMockedProtocolsInheritedProtocols
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ @protocol(SampleProtocol3) ]];
    
    // then
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol2)], @"Mock does not conform to inherited mocked protocol");
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to inherited mocked protocol");
    XCTAssertTrue([mock conformsToProtocol:@protocol(NSObject)], @"Mock does not conform to inherited mocked protocol");
}

- (void)testThatMockConformsToProtocolsOfMockedClass
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ [SampleClass3 class] ]];
    
    // then
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol2)], @"Mock does not conform to inherited mocked protocol");
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to inherited mocked protocol");
    XCTAssertTrue([mock conformsToProtocol:@protocol(NSObject)], @"Mock does not conform to inherited mocked protocol");
}

- (void)testThatMockConformsToProtocolsOfMockedClassSuperclass
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ [SampleClass4 class] ]];
    
    // then
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol2)], @"Mock does not conform to inherited mocked protocol");
    XCTAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to inherited mocked protocol");
    XCTAssertTrue([mock conformsToProtocol:@protocol(NSObject)], @"Mock does not conform to inherited mocked protocol");
}

- (void)testThatMockConformsToAllMockedProtocols
{
    // given
    MCKMockObject *mock =
    [MCKMockObject mockWithContext:nil entities:@[ @protocol(NSObject), @protocol(NSCoding), @protocol(NSCopying) ]];
    
    // then
    XCTAssertTrue([mock conformsToProtocol:@protocol(NSObject)],  @"Mock does not conform to all passed protocols");
    XCTAssertTrue([mock conformsToProtocol:@protocol(NSCoding)],  @"Mock does not conform to all passed protocols");
    XCTAssertTrue([mock conformsToProtocol:@protocol(NSCopying)], @"Mock does not conform to all passed protocols");
}


#pragma mark - Test Weak Retaining

- (void)testThatWeakReferencesToMocksAreNotAutomaticallyClearedIfThereAreStrongRefs
{
    // this is a problem in OCMock and it seems to be on iOS only
    // a weak delegate for example will immediately be nil when a mock is assigned
    // even though a strong reference is still there
    
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ @protocol(NSObject) ]];
    DelegateHolder *holder = [[DelegateHolder alloc] init];
    
    holder.delegate = mock;
    
    XCTAssertNotNil(holder.delegate, @"Delegate should still be available");
    XCTAssertNotNil(mock, @"Ok something got out of hand..."); // second test is to still use the mock, so the strong ref is not cleared
}


#pragma mark - Test Category Methods

- (void)testThatMockRespondsToSelectorsOfCategories
{
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil entities:@[ [CategoriesTestMockedClass class] ]];
    
    // then
    XCTAssertTrue([mock respondsToSelector:@selector(categoryMethodInMockedClass)], @"Mock does not respond to selector of category");
    XCTAssertTrue([mock respondsToSelector:@selector(categoryMethodInMockedClassSuperclass)], @"Mock does not respond to selector of category");
    XCTAssertTrue([mock respondsToSelector:@selector(categoryMethodInNSObject)], @"Mock does not respond to selector of category");
}

@end
