//
//  MCKMockingSyntax.h
//  mocka
//
//  Created by Markus Gasser on 25.9.2013.
//
//

#import <Foundation/Foundation.h>

#import "MCKLocation.h"

@class MCKStub;


#pragma mark - Creating Mocks and Spies

// safe syntax
#define mck_mock(CLS, ...)        _mck_createMock(self, _MCKCurrentLocation(), @[ (CLS), ## __VA_ARGS__ ])
#define mck_mockForClass(CLS)     (CLS *)mck_mock([CLS class])
#define mck_mockForProtocol(PROT) (id<PROT>)mck_mock(@protocol(PROT))
#define mck_spy(OBJ)              (typeof(OBJ))_mck_createSpy(self, _MCKCurrentLocation(), (OBJ))

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define mock(CLS, ...)        mck_mock(CLS, __VA_ARGS__)
    #define mockForClass(CLS)     mck_mockForClass(CLS)
    #define mockForProtocol(PROT) mck_mockForProtocol(PROT)
    #define spy(OBJ)              mck_spy(OBJ)

#endif


#pragma mark - Verification

// safe syntax
#define mck_verifyCall(...)               mck_verifyCallWithTimeout(0.0, __VA_ARGS__)
#define mck_verifyCallWithTimeout(T, ...) _mck_beginVerifyWithTimeout(self, _MCKCurrentLocation(), (T)); (void)(__VA_ARGS__)

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define verifyCall(...)               mck_verifyCall(__VA_ARGS__)
    #define verifyCallWithTimeout(T, ...) mck_verifyCallWithTimeout(T, __VA_ARGS__)

#endif


#pragma mark - Stubbing

// safe syntax
#define mck_stubCall(CALL)  _mck_stubCalls(self, _MCKCurrentLocation(), ^{ (CALL); }).stubBlock = ^typeof(CALL)
#define mck_stubCalls(CALL) _mck_stubCalls(self, _MCKCurrentLocation(), ^{ (CALL); }).stubBlock = ^
#define mck_with


// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define stubCall(CALL)  mck_stubCall(CALL)
    #define stubCalls(CALL) mck_stubCalls(CALL)
    #define with            mck_with

#endif


#pragma mark - Internal Bridging

extern id _mck_createMock(id testCase, MCKLocation *location, NSArray *classAndProtocols);
extern id _mck_createSpy(id testCase, MCKLocation *location, id object);
extern void _mck_beginVerifyWithTimeout(id testCase, MCKLocation *location, NSTimeInterval timeout);
extern MCKStub* _mck_stubCalls(id testCase, MCKLocation *location, void(^calls)(void));
extern void _mck_updateLocationInfo(MCKLocation *location);
