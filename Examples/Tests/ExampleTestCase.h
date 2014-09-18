//
//  ExampleTestCase.h
//  Examples
//
//  Created by Markus Gasser on 07.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>


@interface ExampleTestCase : XCTestCase

- (void)mck_executeWithExceptionFailures:(void(^)(void))block;

@end


#define ThisWillNotCompile(...)

#define ThisWillFail(...) {\
    @try { \
        [self mck_executeWithExceptionFailures:^{ __VA_ARGS__; }]; \
        XCTFail(@"This should have failed"); \
    } @catch (id ex) {}\
}


extern BOOL WaitForCondition(NSTimeInterval timeout, BOOL(^condition)(void));
