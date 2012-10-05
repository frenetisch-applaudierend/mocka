//
//  FakeTestCase.h
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FakeTestCase : NSObject

- (void)failWithException:(NSException *)exception;

@property (nonatomic, readonly) NSException *lastReportedFailure;

@end
