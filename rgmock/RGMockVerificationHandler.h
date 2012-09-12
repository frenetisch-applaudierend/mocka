//
//  RGMockVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"


@protocol RGMockVerificationHandler <NSObject>

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
            withNonObjectArgumentMatchers:(NSArray *)argumentMatchers
                    inRecordedInvocations:(NSArray *)recordedInvocations
                                satisfied:(BOOL *)satisified;

@end


// Setting a verification handler
#define mock_setVerificationHandler(handler) if (mock_setVerificationHandlerOnContext(mock_updatedContext(), (handler)))
static BOOL mock_setVerificationHandlerOnContext(RGMockContext *context, id<RGMockVerificationHandler> handler) {
    [context setVerificationHandler:handler];
    return YES;
}
