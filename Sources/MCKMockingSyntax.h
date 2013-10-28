//
//  MCKMockingSyntax.h
//  mocka
//
//  Created by Markus Gasser on 25.9.2013.
//
//

#import <Foundation/Foundation.h>


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
#define mck_verify(CALL)               _mck_beginVerify(self, __FILE__, __LINE__, 0.0, ^{ (CALL); });
#define mck_verifyWithTimeout(T, CALL) _mck_beginVerify(self, __FILE__, __LINE__, (T), ^{ (CALL); });

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #undef verify // under Mac OS X this macro defined already (in /usr/include/AssertMacros.h)

    #define verify(CALL)               mck_verify(CALL)
    #define verifyWithTimeout(T, CALL) mck_verifyWithTimeout(T, CALL)

#endif


#pragma mark - Stubbing

// safe syntax
#define mck_whenCalling(CALL) _mck_beginStub(self, __FILE__, __LINE__, ^{ (CALL); });
#define mck_thenDo(ACTIONS)   (ACTIONS)

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define whenCalling(CALL) mck_whenCalling(CALL)
    #define thenDo(ACTIONS)   mck_thenDo(ACTIONS)

#endif


#pragma mark - Internal Bridging

typedef void(^MCKCallBlock)(void);

extern id _mck_createMock(id testCase, const char *fileName, NSUInteger lineNumber, NSArray *classAndProtocols);
extern id _mck_createSpy(id testCase, const char *fileName, NSUInteger lineNumber, id object);

extern void _mck_beginVerify(id testCase, const char *fileName, NSUInteger lineNumber, NSTimeInterval timeout, MCKCallBlock calls);
extern void _mck_beginStub(id testCase, const char *fileName, NSUInteger lineNumber, MCKCallBlock calls);
extern void _mck_updateLocationInfo(const char *fileName, NSUInteger lineNumber);
