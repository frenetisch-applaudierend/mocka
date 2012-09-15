//
//  RGMockTestCase.h
//  rgmock
//
//  Created by Markus Gasser on 15.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


#define AssertDoesNotFail(...) [self mock_interceptFailuresInFile:[NSString stringWithUTF8String:__FILE__] line:__LINE__ block:^{ __VA_ARGS__ } shouldFail:NO];
#define AssertFails(...) [self mock_interceptFailuresInFile:[NSString stringWithUTF8String:__FILE__] line:__LINE__ block:^{ __VA_ARGS__ } shouldFail:YES];


@interface RGMockTestCase : SenTestCase

- (void)mock_interceptFailuresInFile:(NSString *)file line:(int)line block:(void(^)())block shouldFail:(BOOL)shouldFail;

@end
