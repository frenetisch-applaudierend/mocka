//
//  MCKStubbingSyntax.m
//  mocka
//
//  Created by Markus Gasser on 8.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKStubbingSyntax.h"
#import "MCKMockingContext.h"


MCKStub* _mck_stub(id testCase, MCKLocation *location, void(^calls)(void)) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.currentLocation = location;
    return [context stubCalls:calls];
}
