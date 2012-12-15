//
//  FakeFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 16.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeFailureHandler.h"

@implementation FakeFailureHandler {
    NSMutableArray *_capturedFailures;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _capturedFailures = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Handling Failures

- (NSArray *)capturedFailures {
    return [_capturedFailures copy];
}

- (void)handleFailureWithReason:(NSString *)reason {
    [_capturedFailures addObject:[CapturedFailure failureWithFileName:self.fileName lineNumber:self.lineNumber reason:reason]];
}

@end


@implementation CapturedFailure

+ (id)failureWithFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber reason:(NSString *)reason {
    return [[self alloc] initWithFileName:fileName lineNumber:lineNumber reason:reason];
}

- (id)initWithFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber reason:(NSString *)reason {
    if ((self = [super init])) {
        _fileName = [fileName copy];
        _lineNumber = lineNumber;
        _reason = [reason copy];
    }
    return self;
}

@end