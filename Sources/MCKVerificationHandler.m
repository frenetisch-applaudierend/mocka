//
//  MCKVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKVerificationHandler.h"

#import "MCKMockingContext+MCKVerification.h"


void _mck_setVerificationHandlerImpl(id<MCKVerificationHandler> handler) {
    [[MCKMockingContext currentContext] useVerificationHandler:handler];
}
