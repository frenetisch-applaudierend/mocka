//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 25.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerification.h"


@class MCKVerificationRecorder;
@class MCKMockingContext;
@class MCKLocation;
@protocol MCKVerificationHandler;


extern MCKVerificationRecorder* _mck_verificationRecorder(MCKMockingContext *context, MCKLocation *location) NS_RETURNS_RETAINED;


@interface MCKVerificationRecorder : NSObject

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context location:(MCKLocation *)location;

@property (nonatomic, readonly) MCKMockingContext *mockingContext;
@property (nonatomic, readonly) MCKLocation *location;


#pragma mark - Properties

@property (nonatomic, readonly) MCKVerificationBlock verificationBlock;
@property (nonatomic, readonly) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readonly) NSNumber *timeout;

@end
