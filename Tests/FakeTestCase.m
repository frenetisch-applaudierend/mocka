//
//  FakeTestCase.m
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "FakeTestCase.h"

@implementation FakeTestCase

- (void)failWithException:(NSException *)exception {
    _lastReportedFailure = exception;
}

@end
