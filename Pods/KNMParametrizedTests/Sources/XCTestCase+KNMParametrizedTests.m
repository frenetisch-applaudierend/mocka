//
//  XCTestCase+KNMParametrizedTests.m
//  konoma-parametrized-tests
//
//  Created by Markus Gasser on 24.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "XCTestCase+KNMParametrizedTests.h"
#import "KNMParametrizedTestCaseScanner.h"
#import "KNMInvocationBuilder.h"
#import "KNMParametrizedTestsValues.h"

#import <objc/runtime.h>


#define SWIZZLE_INSTANCE_METHODS(CLS, S1, S2) method_exchangeImplementations(\
    class_getInstanceMethod((CLS), (S1)),\
    class_getInstanceMethod((CLS), (S2))\
)

#define SWIZZLE_CLASS_METHODS(CLS, S1, S2) method_exchangeImplementations(\
    class_getClassMethod((CLS), (S1)),\
    class_getClassMethod((CLS), (S2))\
)

static NSUInteger KNMInvocationIndexKey;


@implementation XCTestCase (KNMParametrizedTests)

#pragma mark - Initialization

+ (void)load
{
    // "override" -name
    SWIZZLE_INSTANCE_METHODS(self, @selector(name), @selector(knm_name));
    
    // "override" +testInvocations with our +knm_allTestInvocations, but backup the
    // original +testInvocations method first into +knm_defaultTestInvocations.
    // That's not technically necessary but it makes the methods a bit more consistent below.
    SWIZZLE_CLASS_METHODS(self, @selector(testInvocations), @selector(knm_defaultTestInvocations));
    SWIZZLE_CLASS_METHODS(self, @selector(testInvocations), @selector(knm_allTestInvocations));
}


#pragma mark - Adding Test Cases

+ (NSArray *)knm_allTestInvocations
{
    NSMutableArray *invocations = [NSMutableArray array];
    [invocations addObjectsFromArray:[self knm_defaultTestInvocations]];
    [invocations addObjectsFromArray:[self knm_parametrizedTestInvocations]];
    return invocations;
}

+ (NSArray *)knm_defaultTestInvocations
{
    return nil; // will be replaced by original implementation of +testInvocations
}

+ (NSArray *)knm_parametrizedTestInvocations
{
    NSMutableArray *parametrizedInvocations = [NSMutableArray array];
    
    NSArray *selectors = [[KNMParametrizedTestCaseScanner scanner] selectorsForParametrizedTestsInClass:self];
    for (NSString *selectorName in selectors) {
        NSArray *invocations = [self knm_invocationsForParametrizedTestWithSelector:NSSelectorFromString(selectorName)];
        [parametrizedInvocations addObjectsFromArray:invocations];
    }
    
    return parametrizedInvocations;
}

+ (NSArray *)knm_invocationsForParametrizedTestWithSelector:(SEL)selector
{
    NSArray *parameters = [self parametersForTestWithSelector:selector];
    NSMutableArray *invocations = [NSMutableArray array];
    
    [parameters enumerateObjectsUsingBlock:^(id parameter, NSUInteger idx, BOOL *stop) {
        NSInvocation *invocation = [[KNMInvocationBuilder builder] buildTestInvocationForSelector:selector inClass:self withParameter:parameter];
        objc_setAssociatedObject(invocation, &KNMInvocationIndexKey, @(idx), OBJC_ASSOCIATION_COPY_NONATOMIC);
        [invocations addObject:invocation];
    }];
    
    return invocations;
}


#pragma mark - Configuration

- (NSString *)knm_name
{
    NSInvocation *invocation = [self invocation];
    if (![NSStringFromSelector(invocation.selector) hasSuffix:@":"]) {
        return [self knm_name]; // original name
    }
    
    // make sure the name does not have the : in it, otherwise Xcode won't display errors for this test
    // also add the test index to make the name unique
    NSString *name = [self knm_name];
    NSUInteger idx = [objc_getAssociatedObject(invocation, &KNMInvocationIndexKey) unsignedIntegerValue];
    NSString *identifier = [NSString stringWithFormat:@"_%lu", (unsigned long)idx];
    return [name stringByReplacingCharactersInRange:NSMakeRange((name.length - 2), 1) withString:identifier];
}


#pragma mark - Getting Parameters

+ (NSArray *)parametersForTestWithSelector:(SEL)selector
{
    SEL providerSelector = [[KNMParametrizedTestCaseScanner scanner] parameterProviderForTestWithSelector:selector inClass:self];
    if (providerSelector == NULL) {
        return @[ knm_NIL ];
    }
    
    IMP provider = [self methodForSelector:providerSelector];
    return ((id (*)(id, SEL))provider)(self, providerSelector);
}

@end
