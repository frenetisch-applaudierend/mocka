//
//  ExamplesCommon.h
//  mocka
//
//  Created by Markus Gasser on 17.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mocka.h"
#import "TestExceptionUtils.h"
#import "TestObject.h"


#define SetupExampleErrorHandler() [[MCKMockingContext contextForTestCase:self] setFailureHandler:[[MCKExceptionFailureHandler alloc] init]]

#define ThisWillFail(...) AssertFails(__VA_ARGS__)
static inline void IgnoreUnused(id var, ...) { }
