//
//  TestExceptionUtils.h
//  mocka
//
//  Created by Markus Gasser on 15.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKExceptionFailureHandler.h"

#define IgnoreFailures(...) InExceptionReporter({\
    @try { __VA_ARGS__; } @catch (id ex) {}\
})

#define AssertDoesNotFail(...) InExceptionReporter({\
    @try { __VA_ARGS__; } @catch (id ex) { STFail(@"This should not have failed (Failed with %@", ex); }\
})

#define AssertFails(...) InExceptionReporter({\
    @try { __VA_ARGS__; STFail(@"This should have failed"); } @catch (id ex) {}\
})

#define AssertFailsWith(msg, file, line, ...) InExceptionReporter({\
    @try { __VA_ARGS__; STFail(@"This should have failed with %@", (msg)); }\
    @catch (NSException *ex) {\
        if ((msg) != nil)  STAssertEqualObjects(ex.reason, (msg), @"This should have failed with reason %@", (msg));\
        if ((file) != nil) STAssertEqualObjects(ex.userInfo[MCKFileNameKey], (file), @"This should have failed with file %@", (file));\
        if ((line) > 0)    STAssertEqualObjects(ex.userInfo[MCKLineNumberKey], @(line), @"This should have failed with line %@", @(line));\
    }\
})

#define InExceptionReporter(...) {\
    id backup = [[MCKMockingContext contextForTestCase:self] failureHandler];\
    [[MCKMockingContext contextForTestCase:self] setFailureHandler:[[MCKExceptionFailureHandler alloc] init]];\
    do { __VA_ARGS__; } while(0);\
    [[MCKMockingContext contextForTestCase:self] setFailureHandler:backup];\
}

