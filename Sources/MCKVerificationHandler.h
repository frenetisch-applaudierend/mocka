//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"

@class MCKInvocationCollection;
@class MCKArgumentMatcherCollection;


@protocol MCKVerificationHandler <NSObject>

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)matchers
                    inRecordedInvocations:(MCKInvocationCollection *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage;

@end


// Setting a verification handler
#define mck_setVerificationHandler(handler) if (mck_setVerificationHandlerOnContext(mck_currentContext(), (handler)))

static BOOL mck_setVerificationHandlerOnContext(MCKMockingContext *context, id<MCKVerificationHandler> handler) {
    [context setVerificationHandler:handler];
    return YES;
}
