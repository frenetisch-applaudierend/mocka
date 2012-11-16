//
//  MCKVerifyNoInteractions.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKVerifyNoInteractions.h"
#import "MCKMockingContext.h"


void mck_checkNoInteractions(MCKMockingContext *context, id mockObject) {
    for (NSInvocation *invocation in context.recordedInvocations.allInvocations) {
        if (invocation.target == mockObject) {
            [context failWithReason:@"Expected no more interactions on %@, but still had", mockObject];
            break;
        }
    }
    [context updateContextMode:MCKContextModeRecording];
}
