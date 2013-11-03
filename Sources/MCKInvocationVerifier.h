//
//  MCKInvocationVerifier.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKInvocationVerifierDelegate;
@protocol MCKVerificationHandler;
@protocol MCKVerificationResultCollector;
@class MCKInvocationPrototype;


@interface MCKInvocationVerifier : NSObject

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, weak) id<MCKInvocationVerifierDelegate> delegate;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;

- (void)verifyInvocations:(NSMutableArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

- (void)beginGroupRecordingWithCollector:(id<MCKVerificationResultCollector>)collector;
- (void)finishGroupRecording;

@end


@protocol MCKInvocationVerifierDelegate <NSObject>

- (void)invocationVerifier:(MCKInvocationVerifier *)verififer didFailWithReason:(NSString *)reason;
- (void)invocationVerifierDidEnd:(MCKInvocationVerifier *)verififer;

- (void)invocationVerifierWillProcessTimeout:(MCKInvocationVerifier *)verififer;
- (void)invocationVerifierDidProcessTimeout:(MCKInvocationVerifier *)verififer;

@end
