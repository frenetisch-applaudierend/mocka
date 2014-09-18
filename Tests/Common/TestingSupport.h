//
//  TestingSupport.h
//  mocka
//
//  Created by Markus Gasser on 4.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

// Test Objects
#import "AsyncService.h"
#import "CategoriesTestClasses.h"
#import "TestObject.h"

// Test Matchers
#import "HCMatcher.h"
#import "HCBlockMatcher.h"

// Fakes
#import "FakeMockingContext.h"
#import "FakeInvocationStubber.h"
#import "FakeInvocationPrototype.h"

// Utilities
#import "TestExceptionUtils.h"
#import "TestTimingUtils.h"
#import "NSInvocation+TestSupport.h"
