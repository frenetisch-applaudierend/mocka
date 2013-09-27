//
//  MCKBlockArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKArgumentMatcher.h"
#import "MCKArgumentSerialization.h"


@interface MCKBlockArgumentMatcher : NSObject <MCKArgumentMatcher>

@property (nonatomic, copy) BOOL(^matcherBlock)(id candidate);

+ (id)matcherWithBlock:(BOOL(^)(id candidate))block;

@end


// Mocking Syntax
static inline id mck_matchObject(BOOL(^block)(id candidate)) {
    return mck_registerObjectMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeObjectArgument(candidate));
    }]);
}

static inline char mck_matchSignedInt(BOOL(^block)(SInt64 candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeSignedIntegerArgument(candidate));
    }]);
}

static inline char mck_matchUnsignedInt(BOOL(^block)(UInt64 candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeUnsignedIntegerArgument(candidate));
    }]);
}

static inline float mck_matchFloat(BOOL(^block)(float candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeFloatingPointArgument(candidate));
    }]);
}

static inline double mck_matchDouble(BOOL(^block)(double candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeFloatingPointArgument(candidate));
    }]);
}

static inline BOOL mck_matchBool(BOOL(^block)(BOOL candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeBooleanArgument(candidate));
    }]);
}

static inline char* mck_matchCString(BOOL(^block)(const char* candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerCStringMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeCStringArgument(candidate));
    }], MCKDefaultCStringBuffer);
}

static inline SEL mck_matchSelector(BOOL(^block)(SEL candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerSelectorMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeSelectorArgument(candidate));
    }]);
}

static inline void* mck_matchPointer(BOOL(^block)(void* candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPointerMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodePointerArgument(candidate));
    }]);
}

static inline __autoreleasing id* mck_matchObjectPointer(BOOL(^block)(id* candidate)) {
    NSCParameterAssert(block != nil);
    return (__autoreleasing id *)mck_registerPointerMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block((__autoreleasing id *)mck_decodePointerArgument(candidate));
    }]);
}

#define mck_matchStruct(structType, matcherBlock) mck_registerStructMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {\
                                                    structType val; [candidate getValue:&val]; BOOL(^block)(structType) = matcherBlock;\
                                                    return block(val); }], structType)


#ifndef MOCK_DISABLE_NICE_SYNTAX
static inline id matchObject(BOOL(^block)(id candidate)) { return mck_matchObject(block); }
static inline char matchSignedInt(BOOL(^block)(SInt64 candidate)) { return mck_matchSignedInt(block); }
static inline char matchUnsignedInt(BOOL(^block)(UInt64 candidate)) { return mck_matchUnsignedInt(block); }
static inline float matchFloat(BOOL(^block)(float candidate)) { return mck_matchFloat(block); }
static inline double matchDouble(BOOL(^block)(double candidate)) { return mck_matchDouble(block); }
static inline BOOL matchBool(BOOL(^block)(BOOL candidate)) { return mck_matchBool(block); }
static inline char* matchCString(BOOL(^block)(const char* candidate)) { return mck_matchCString(block); }
static inline SEL matchSelector(BOOL(^block)(SEL candidate)) { return mck_matchSelector(block); }
static inline void* matchPointer(BOOL(^block)(void* candidate)) { return mck_matchPointer(block); }
static inline __autoreleasing id* matchObjectPointer(BOOL(^block)(id* candidate)) { return mck_matchObjectPointer(block); }
#define matchStruct(structType, matcherBlock) mck_matchStruct(structType, matcherBlock)
#endif
