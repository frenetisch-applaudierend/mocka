//
//  MCKMockObjectTest.m
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKMockObject.h"

#import "FakeMockingContext.h"
#import "TestObject.h"
#import "CategoriesTestClasses.h"


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


@interface MCKMockObjectTest : SenTestCase
@end

@implementation MCKMockObjectTest

#pragma mark - Test Initializer

- (void)testThatInitializerFailsForEmptyClassOrProtocolList {
    STAssertThrows([MCKMockObject mockWithContext:[FakeMockingContext fakeContext] classAndProtocols:@[]],
                   @"Should fail for empty class and protocol list");
}

- (void)testThatInitializerFailsIfObjectIsPassedWhichIsNotClassOrProtocol {
    NSArray *invalidClassOrProtocolList = @[ [TestObject class], @protocol(NSCoding), @"Fail here" ];
    STAssertThrows([MCKMockObject mockWithContext:[FakeMockingContext fakeContext] classAndProtocols:invalidClassOrProtocolList],
                   @"Should fail for object which is not class or protocol");
}

- (void)testThatInitializerFailsIfMultipleClassesArePassed {
    NSArray *invalidClassOrProtocolList = @[ [TestObject class], [NSObject class] ];
    STAssertThrows([MCKMockObject mockWithContext:[FakeMockingContext fakeContext] classAndProtocols:invalidClassOrProtocolList],
                   @"Should fail for multiple classes in list");
}


#pragma mark - Test Forwarding Invocations

- (void)testThatForwardInvocationCallsMockingContextsHandleInvocation {
    // given
    FakeMockingContext *fakeContext = [FakeMockingContext fakeContext];
    MCKMockObject *mock = [MCKMockObject mockWithContext:(id)fakeContext classAndProtocols:@[ [NSObject class] ]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    
    // when
    [mock forwardInvocation:invocation];
    
    // then
    STAssertEquals([fakeContext.handledInvocations count], (NSUInteger)1, @"Wrong number of handled invocations");
    STAssertEqualObjects(fakeContext.handledInvocations[0], invocation, @"Wrong invocation handled");
}


#pragma mark - Test -respondsToSelector:

- (void)testThatRespondsToSelectorReturnsTrueForSelectorOnPassedClass {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ [TestObject class] ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(voidMethodCallWithoutParameters)], @"Mock does not respond to instance method of class");
}

- (void)testThatRespondsToSelectorReturnsTrueForSelectorOnPassedProtocol {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ @protocol(NSCoding) ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(encodeWithCoder:)], @"Mock does not respond to instance method of class");
}

- (void)testThatRespondsToSelectorReturnsTrueForSelectorsIfBothClassAndProtocolArePassed {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil
                                                                 classAndProtocols:@[ [TestObject class], @protocol(NSCoding) ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(voidMethodCallWithoutParameters)], @"Mock does not respond to instance method of class");
    STAssertTrue([mock respondsToSelector:@selector(encodeWithCoder:)], @"Mock does not respond to instance method of class");
}


#pragma mark - Test -isKindOfClass: and -conformsToProtocol:

- (void)testThatMockIsKindOfMockedClass {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ [SampleClass1 class] ]];
    
    // then
    STAssertTrue([mock isKindOfClass:[SampleClass1 class]], @"Mock is not a kind of the mocked class");
}

- (void)testThatMockIsKindOfMockedClassSuperclass {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ [SampleClass2 class] ]];
    
    // then
    STAssertTrue([mock isKindOfClass:[SampleClass1 class]], @"Mock is not a kind of the inherited mocked class");
}

- (void)testThatMockConformsToMockedProtocols {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ @protocol(SampleProtocol1) ]];
    
    // then
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to mocked protocol");
}

- (void)testThatMockConformsToMockedProtocolsInheritedProtocols {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ @protocol(SampleProtocol3) ]];
    
    // then
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol2)], @"Mock does not conform to inherited mocked protocol");
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to inherited mocked protocol");
    STAssertTrue([mock conformsToProtocol:@protocol(NSObject)], @"Mock does not conform to inherited mocked protocol");
}

- (void)testThatMockConformsToProtocolsOfMockedClass {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ [SampleClass3 class] ]];
    
    // then
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol2)], @"Mock does not conform to inherited mocked protocol");
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to inherited mocked protocol");
    STAssertTrue([mock conformsToProtocol:@protocol(NSObject)], @"Mock does not conform to inherited mocked protocol");
}

- (void)testThatMockConformsToProtocolsOfMockedClassSuperclass {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ [SampleClass4 class] ]];
    
    // then
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol2)], @"Mock does not conform to inherited mocked protocol");
    STAssertTrue([mock conformsToProtocol:@protocol(SampleProtocol1)], @"Mock does not conform to inherited mocked protocol");
    STAssertTrue([mock conformsToProtocol:@protocol(NSObject)], @"Mock does not conform to inherited mocked protocol");
}

- (void)testThatMockConformsToAllMockedProtocols {
    // given
    MCKMockObject *mock =
    [MCKMockObject mockWithContext:nil classAndProtocols:@[ @protocol(NSObject), @protocol(NSCoding), @protocol(NSCopying) ]];
    
    // then
    STAssertTrue([mock conformsToProtocol:@protocol(NSObject)],  @"Mock does not conform to all passed protocols");
    STAssertTrue([mock conformsToProtocol:@protocol(NSCoding)],  @"Mock does not conform to all passed protocols");
    STAssertTrue([mock conformsToProtocol:@protocol(NSCopying)], @"Mock does not conform to all passed protocols");
}


#pragma mark - Test Weak Retaining

- (void)testThatWeakReferencesToMocksAreNotAutomaticallyClearedIfThereAreStrongRefs {
    // this is a problem in OCMock and it seems to be on iOS only
    // a weak delegate for example will immediately be nil when a mock is assigned
    // even though a strong reference is still there
    
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ @protocol(NSObject) ]];
    DelegateHolder *holder = [[DelegateHolder alloc] init];
    
    holder.delegate = mock;
    
    STAssertNotNil(holder.delegate, @"Delegate should still be available");
    STAssertNotNil(mock, @"Ok something got out of hand..."); // second test is manly to still use the mock, so the strong ref is not deemed unused
}


#pragma mark - Test Category Methods

- (void)testThatMockRespondsToSelectorsOfCategories {
    // given
    MCKMockObject *mock = [MCKMockObject mockWithContext:nil classAndProtocols:@[ [CategoriesTestMockedClass class] ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(categoryMethodInMockedClass)], @"Mock does not respond to selector of category");
    STAssertTrue([mock respondsToSelector:@selector(categoryMethodInMockedClassSuperclass)], @"Mock does not respond to selector of category");
    STAssertTrue([mock respondsToSelector:@selector(categoryMethodInNSObject)], @"Mock does not respond to selector of category");
}

@end
