//
//  MCKVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKVerificationHandler.h"

#import "MCKMockingContext.h"


id<MCKVerificationHandler> _mck_getVerificationHandler(void) {
    return [[MCKMockingContext currentContext] verificationHandler];
}

void _mck_setVerificationHandler(id<MCKVerificationHandler> handler) {
    [[MCKMockingContext currentContext] setVerificationHandler:handler];
}
