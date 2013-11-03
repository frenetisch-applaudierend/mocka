//
//  MCKMockingSyntax.m
//  mocka
//
//  Created by Markus Gasser on 25.9.2013.
//
//

#import "MCKMockingSyntax.h"

#import "MCKMockingContext.h"
#import "MCKMockObject.h"
#import "MCKSpy.h"


id _mck_createMock(id testCase, MCKLocation *location, NSArray *classAndProtocols) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.currentLocation = location;
    return [MCKMockObject mockWithContext:context classAndProtocols:classAndProtocols];
}

id _mck_createSpy(id testCase, MCKLocation *location, id object) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.currentLocation = location;
    return mck_createSpyForObject(object, context);
}

void _mck_beginVerifyWithTimeout(id testCase, MCKLocation *location, NSTimeInterval timeout) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.currentLocation = location;
    [context beginVerificationWithTimeout:timeout];
}

MCKStub* _mck_stubCalls(id testCase, MCKLocation *location, void(^calls)(void)) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.currentLocation = location;
    [context beginStubbing];
    calls();
    [context endStubbing];
    
    return context.activeStub;
}

void _mck_updateLocationInfo(MCKLocation *location) {
    [[MCKMockingContext currentContext] setCurrentLocation:location];
}
