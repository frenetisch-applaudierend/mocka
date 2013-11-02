//
//  MCKMockingSyntax.h
//  mocka
//
//  Created by Markus Gasser on 25.9.2013.
//
//

#import <Foundation/Foundation.h>

@class MCKStub;


#pragma mark - Creating Mocks and Spies

// safe syntax
#define mck_mock(CLS, ...)        _mck_createMock(self, __FILE__, __LINE__, @[ CLS, __VA_ARGS__ ])
#define mck_mockForClass(CLS)     (CLS *)mck_mock([CLS class])
#define mck_mockForProtocol(PROT) (id<PROT>)mck_mock(@protocol(PROT))
#define mck_spy(OBJ)              (typeof(OBJ))_mck_createSpy(self, __FILE__, __LINE__, OBJ)

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define mock(CLS, ...)        mck_mock(CLS, __VA_ARGS__)
    #define mockForClass(CLS)     mck_mockForClass(CLS)
    #define mockForProtocol(PROT) mck_mockForProtocol(PROT)
    #define spy(OBJ)              mck_spy(OBJ)

#endif


#pragma mark - Verification

// safe syntax
#define mck_verifyCall               mck_verifyCallWithTimeout(0.0)
#define mck_verifyCallWithTimeout(T) _mck_beginVerifyWithTimeout(self, __FILE__, __LINE__, (T));

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define verifyCall               mck_verifyCall
    #define verifyCallWithTimeout(T) mck_verifyCallWithTimeout(T)

#endif


#pragma mark - Stubbing

// safe syntax
#define mck_whenCalling _mck_beginStub(self, __FILE__, __LINE__);
#define mck_thenDo      ;

#define mck_stubCall(CALL) _mck_stubCalls(self, __FILE__, __LINE__, ^{ (CALL); }).stubBlock = ^typeof(CALL)
#define mck_with


// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define whenCalling mck_whenCalling
    #define thenDo      mck_thenDo

    #define stubCall(CALL) mck_stubCall(CALL)
    #define with           mck_with

#endif


#pragma mark - Internal Bridging

extern id _mck_createMock(id testCase, const char *fileName, NSUInteger lineNumber, NSArray *classAndProtocols);
extern id _mck_createSpy(id testCase, const char *fileName, NSUInteger lineNumber, id object);
extern void _mck_beginVerifyWithTimeout(id testCase, const char *fileName, NSUInteger lineNumber, NSTimeInterval timeout);
extern void _mck_beginStub(id testCase, const char *fileName, NSUInteger lineNumber);
extern MCKStub* _mck_stubCalls(id testCase, const char *fileName, NSUInteger lineNumber, void(^calls)(void));
extern void _mck_updateLocationInfo(const char *fileName, NSUInteger lineNumber);
