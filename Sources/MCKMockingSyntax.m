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


id _mck_createMock(id testCase, const char *fileName, NSUInteger lineNumber, NSArray *classAndProtocols) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    [context updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
    return [MCKMockObject mockWithContext:context classAndProtocols:classAndProtocols];
}

id _mck_createSpy(id testCase, const char *fileName, NSUInteger lineNumber, id object) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    [context updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
    return mck_createSpyForObject(object, context);
}

void _mck_beginVerifyWithTimeout(id testCase, const char *fileName, NSUInteger lineNumber, NSTimeInterval timeout) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    [context updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
    [context beginVerificationWithTimeout:timeout];
}

MCKStub* _mck_stubCalls(id testCase, const char *fileName, NSUInteger lineNumber, void(^calls)(void)) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    [context updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
    [context beginStubbing];
    
    calls();
    [context addStubAction:nil]; // notify end of stubbing
    
    return context.activeStub;
}

void _mck_updateLocationInfo(const char *fileName, NSUInteger lineNumber) {
    [[MCKMockingContext currentContext] updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
}
