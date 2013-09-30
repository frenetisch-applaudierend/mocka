//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mocka/MCKVerificationResult.h>
#import <Mocka/MCKInvocationPrototype.h>


@protocol MCKVerificationHandler <NSObject>

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

@end


extern id<MCKVerificationHandler> _mck_getVerificationHandler(void);
extern void _mck_setVerificationHandler(id<MCKVerificationHandler> handler);
