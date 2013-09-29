//
//  MCKFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCKFailureHandler : NSObject

#pragma mark - Getting a Failure Handler

+ (instancetype)failureHandlerForTestCase:(id)testCase;


#pragma mark - Getting and Updating Location Information

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger lineNumber;

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber;


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason;

@end
