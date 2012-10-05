//
//  RGMockTestCase.h
//  rgmock
//
//  Created by Markus Gasser on 15.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockExceptionFailureHandler.h"

#define IgnoreFailures(...) @try { __VA_ARGS__; } @catch (id ex) {}
#define AssertDoesNotFail(...) @try { __VA_ARGS__; } @catch (id ex) { STFail(@"This should not have failed (Failed with %@", ex); }
#define AssertFails(...) @try { __VA_ARGS__; STFail(@"This should have failed"); } @catch (id ex) {}
#define AssertFailsWith(msg, file, line, ...) \
    @try { __VA_ARGS__; STFail(@"This should have failed with %@", (msg)); }\
    @catch (NSException *ex) {\
        if ((msg) != nil)  STAssertEqualObjects(ex.reason, (msg), @"This should have failed with reason %@", (msg));\
        if ((file) != nil) STAssertEqualObjects(ex.userInfo[RGMockFileNameKey], (file), @"This should have failed with file %@", (file));\
        if ((line) > 0)    STAssertEqualObjects(ex.userInfo[RGMockLineNumberKey], @(line), @"This should have failed with line %@", @(line));\
    }
