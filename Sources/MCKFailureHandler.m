//
//  MCKFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 16.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKFailureHandler.h"


@implementation MCKFailureHandler

@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;


#pragma mark - Maintaining Context File Information

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber {
    _fileName = [fileName copy];
    _lineNumber = lineNumber;
}


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
}

@end
