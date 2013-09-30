//
//  MCKVerificationSession.h
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


@interface MCKVerificationSession : NSObject

@property (nonatomic, weak) id<MCKVerificationSessionDelegate> delegate;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;

- (void)verifyInvocations:(NSMutableArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

- (void)beginGroupRecordingWithCollector:(id<MCKVerificationResultCollector>)collector;
- (void)finishGroupRecording;

@end


@protocol MCKVerificationSessionDelegate <NSObject>

- (void)verificationSession:(MCKVerificationSession *)session didFailWithReason:(NSString *)reason;
- (void)verificationSessionDidEnd:(MCKVerificationSession *)session;

@end
