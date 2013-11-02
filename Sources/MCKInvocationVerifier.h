//
//  MCKInvocationVerifier.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKVerificationSessionDelegate;
@protocol MCKVerificationHandler;
@protocol MCKVerificationResultCollector;
@class MCKInvocationPrototype;
@class MCKMockingContext;


@interface MCKInvocationVerifier : NSObject

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, weak) id<MCKVerificationSessionDelegate> delegate;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;

- (void)verifyInvocations:(NSMutableArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

- (void)beginGroupRecordingWithCollector:(id<MCKVerificationResultCollector>)collector;
- (void)finishGroupRecording;

@end


@protocol MCKVerificationSessionDelegate <NSObject>

- (void)verificationSession:(MCKInvocationVerifier *)session didFailWithReason:(NSString *)reason;
- (void)verificationSessionDidEnd:(MCKInvocationVerifier *)session;

- (void)verificationSessionWillProcessTimeout:(MCKInvocationVerifier *)session;
- (void)verificationSessionDidProcessTimeout:(MCKInvocationVerifier *)session;

@end
