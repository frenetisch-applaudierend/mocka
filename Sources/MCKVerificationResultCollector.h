//
//  MCKVerificationResultCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationResult.h"
#import "MCKInvocationRecorder.h"


@protocol MCKVerificationResultCollector <NSObject>

- (void)beginCollectingResultsWithInvocationRecorder:(MCKInvocationRecorder *)invocationRecorder;
- (MCKVerificationResult *)collectVerificationResult:(MCKVerificationResult *)result;
- (MCKVerificationResult *)finishCollectingResults;

@end


#define mck_beginVerifyGroupCallsUsingCollector(COL) _mck_setVerifyGroupCollector(COL); while (_mck_executeGroupCalls(self))


#pragma mark - Internal Bridging Calls

extern void _mck_setVerifyGroupCollector(id<MCKVerificationResultCollector> collector);
extern BOOL _mck_executeGroupCalls(id testCase);
