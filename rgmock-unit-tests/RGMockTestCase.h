//
//  RGMockTestCase.h
//  rgmock
//
//  Created by Markus Gasser on 15.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


#define mock_Intercept(md, expMsg, expFile, expLine, ...) [self mock_interceptFailuresInFile:[NSString stringWithUTF8String:__FILE__] line:__LINE__ block:^{ __VA_ARGS__ } mode:(md) expectedMessage:(expMsg) expectedFile:(expFile) expectedLine:(expLine)]

#define AssertDoesNotFail(...) mock_Intercept(RGMockFailureProhibited, nil, nil, 0, { __VA_ARGS__ })
#define AssertFails(...) mock_Intercept(RGMockFailureRequired, nil, nil, 0, { __VA_ARGS__ })
#define AssertFailsWith(msg, file, line, ...) mock_Intercept(RGMockFailureRequired, (msg), (file), (line), { __VA_ARGS__ })
#define IgnoreFailures(...) mock_Intercept(RGMockFailureIgnored, nil, nil, 0, { __VA_ARGS__ })


typedef enum {
    RGMockFailureProhibited,
    RGMockFailureRequired,
    RGMockFailureIgnored,
} RGMockFailureHandlingMode;

@interface RGMockTestCase : SenTestCase

- (void)mock_interceptFailuresInFile:(NSString *)file line:(int)line block:(void(^)())block mode:(RGMockFailureHandlingMode)mode
                     expectedMessage:(NSString *)message expectedFile:(NSString *)file expectedLine:(NSUInteger)line;

@end
