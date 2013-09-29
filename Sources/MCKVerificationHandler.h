//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKInvocationPrototype;
@class MCKVerificationResult;


@protocol MCKVerificationHandler <NSObject>

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

@end


@interface MCKVerificationResult : NSObject

+ (instancetype)successWithMatchingIndexes:(NSIndexSet *)matches;
+ (instancetype)failureWithReason:(NSString *)reason matchingIndexes:(NSIndexSet *)matches;
- (instancetype)initWithSuccess:(BOOL)success failureReason:(NSString *)failureReason matchingIndexes:(NSIndexSet *)matches;

@property (nonatomic, readonly, getter = isSuccess) BOOL success;
@property (nonatomic, readonly) NSString *failureReason;
@property (nonatomic, readonly) NSIndexSet *matchingIndexes;

@end


extern id<MCKVerificationHandler> _mck_getVerificationHandler(void);
extern void _mck_setVerificationHandler(id<MCKVerificationHandler> handler);
