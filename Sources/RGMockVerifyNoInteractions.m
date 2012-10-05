//
//  RGMockVerifyNoInteractions.m
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockVerifyNoInteractions.h"
#import "RGMockContext.h"


void mck_checkNoInteractions(RGMockContext *context, id mockObject) {
    for (NSInvocation *invocation in context.recordedInvocations) {
        if (invocation.target == mockObject) {
            [context failWithReason:[NSString stringWithFormat:@"Expected no more interactions on %@, but still had", mockObject]];
            break;
        }
    }
    [context updateContextMode:RGMockContextModeRecording];
}
