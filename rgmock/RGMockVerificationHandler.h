//
//  RGMockVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockingContext.h"


@protocol RGMockVerificationHandler <NSObject>

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype inRecordedInvocations:(NSArray *)recordedInvocations;

@end


// Setting a verification handler
static BOOL mock_set_verification_handler_on_context(RGMockingContext *context, id<RGMockVerificationHandler> handler) {
    [context setVerificationHandler:handler];
    return YES;
}
#define mock_verification_handler(handler) if (mock_set_verification_handler_on_context(mock_get_current_context(), (handler)))
