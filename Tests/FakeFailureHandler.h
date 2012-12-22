//
//  FakeFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 16.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKFailureHandler.h"


@interface FakeFailureHandler : MCKFailureHandler

@property (nonatomic, readonly) NSArray *capturedFailures;

@end


@interface CapturedFailure : NSObject

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger lineNumber;
@property (nonatomic, readonly) NSString *reason;

+ (id)failureWithFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber reason:(NSString *)reason;

@end
