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
#import "MCKDefaultVerifier.h"
#import "MCKOrderedVerifier.h"


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

void _mck_beginVerify(id testCase, const char *fileName, NSUInteger lineNumber) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    [context updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
    [context updateContextMode:MCKContextModeVerifying];
}

void _mck_beginStub(id testCase, const char *fileName, NSUInteger lineNumber) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    [context updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
    [context updateContextMode:MCKContextModeStubbing];
}

void _mck_updateLocationInfo(const char *fileName, NSUInteger lineNumber) {
    [[MCKMockingContext currentContext] updateFileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber];
}


@implementation _MCKOrderedVerificationHandler

+ (instancetype)handler {
    static dispatch_once_t onceToken;
    static _MCKOrderedVerificationHandler *handler = nil;
    dispatch_once(&onceToken, ^{
        handler = [[self alloc] init];
    });
    return handler;
}

- (void(^)(void))executeInOrder {
    NSAssert(NO, @"The executeInOrder property is only for internal use and cannot be read");
    return nil;
}

- (void)setExecuteInOrder:(void(^)(void))executeInOrder {
    [self verifyInOrder:executeInOrder];
}

- (void)verifyInOrder:(void (^)(void))verifications {
    NSParameterAssert(verifications != nil);
    [[MCKMockingContext currentContext] setVerifier:[[MCKOrderedVerifier alloc] init]];
    verifications();
    [[MCKMockingContext currentContext] setVerifier:[[MCKDefaultVerifier alloc] init]];
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeRecording];
}

@end
