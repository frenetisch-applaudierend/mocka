//
//  MCKVerificationResultCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mocka/MCKVerificationResult.h>


@protocol MCKVerificationResultCollector <NSObject>

- (void)collectVerificationResult:(MCKVerificationResult *)result;

- (MCKVerificationResult *)resultByMergingResults:(NSArray *)results;

@end


#define mck_beginVerifyGroupCallsUsingCollector(COL) _mck_setVerifyGroupCollector(COL); while (_mck_executeGroupCalls(self))


#pragma mark - Internal Bridging Calls

extern void _mck_setVerifyGroupCollector(id<MCKVerificationResultCollector> collector);
extern BOOL _mck_executeGroupCalls(id testCase);
