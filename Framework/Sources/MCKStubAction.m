//
//  MCKStubAction.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKStubAction.h"

#import "MCKMockingContext.h"


void _mck_addStubAction(id<MCKStubAction> action) {
    [[MCKMockingContext currentContext] addStubAction:action];
}
