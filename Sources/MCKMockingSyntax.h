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
#ifndef MOCK_DISABLE_NICE_SYNTAX

    #define mock(CLS, ...)        mck_mock(CLS, __VA_ARGS__)
    #define mockForClass(CLS)     mck_mockForClass(CLS)
    #define mockForProtocol(PROT) mck_mockForProtocol(PROT)
    #define spy(OBJ)              mck_spy(OBJ)

#endif


#pragma mark - Verification

// safe syntax
#define mck_verify _mck_beginVerify(self, __FILE__, __LINE__);

// nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX

    #undef verify // under Mac OS X this macro defined already (in /usr/include/AssertMacros.h)
    #define verify mck_verify

#endif


#pragma mark - Stubbing

// safe syntax
#define mck_whenCalling _mck_beginStub(self, __FILE__, __LINE__);
#define mck_orCalling   ; mck_whenCalling
#define mck_givenCallTo mck_whenCalling
#define mck_orCallTo    mck_orCalling
#define mck_thenDo      ;
#define mck_andDo       mck_thenDo

// nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX

    #define whenCalling mck_whenCalling
    #define orCalling   mck_orCalling
    #define givenCallTo mck_givenCallTo
    #define orCallTo    mck_orCallTo
    #define thenDo      mck_thenDo
    #define andDo       mck_andDo

#endif


#pragma mark - Internal Bridging

extern id _mck_createMock(id testCase, const char *fileName, NSUInteger lineNumber, NSArray *classAndProtocols);
extern id _mck_createSpy(id testCase, const char *fileName, NSUInteger lineNumber, id object);
extern void _mck_beginVerify(id testCase, const char *fileName, NSUInteger lineNumber);
extern void _mck_beginStub(id testCase, const char *fileName, NSUInteger lineNumber);
extern void _mck_updateLocationInfo(const char *fileName, NSUInteger lineNumber);
