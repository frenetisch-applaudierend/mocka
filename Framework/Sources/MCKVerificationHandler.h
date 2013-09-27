//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKInvocationPrototype;


@protocol MCKVerificationHandler <NSObject>

- (NSIndexSet *)indexesOfInvocations:(NSArray *)invocations
                matchingForPrototype:(MCKInvocationPrototype *)prototype
                           satisfied:(BOOL *)satisified
                      failureMessage:(NSString **)failureMessage;

@end


extern id<MCKVerificationHandler> _mck_getVerificationHandler(void);
extern void _mck_setVerificationHandler(id<MCKVerificationHandler> handler);
