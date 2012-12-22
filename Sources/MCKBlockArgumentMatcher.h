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
static id mck_matchObject(BOOL(^block)(id candidate)) {
    return mck_registerObjectMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block(mck_decodeObjectArgument(candidate));
    }]);
}

static char mck_matchInt(BOOL(^block)(int64_t candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block([candidate longLongValue]);
    }]);
}

static char mck_matchUnsignedInt(BOOL(^block)(uint64_t candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block([candidate unsignedLongLongValue]);
    }]);
}

static float mck_matchFloat(BOOL(^block)(float candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block([candidate floatValue]);
    }]);
}

static double mck_matchDouble(BOOL(^block)(double candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block([candidate doubleValue]);
    }]);
}

static BOOL mck_matchBool(BOOL(^block)(BOOL candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPrimitiveNumberMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block([candidate boolValue]);
    }]);
}

static char* mck_matchCString(BOOL(^block)(char* candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerCStringMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block((char *)[candidate pointerValue]);
    }], MCKDefaultCStringBuffer);
}

static SEL mck_matchSelector(BOOL(^block)(SEL candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerSelectorMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block((SEL)[candidate pointerValue]);
    }]);
}

static void* mck_matchPointer(BOOL(^block)(void* candidate)) {
    NSCParameterAssert(block != nil);
    return mck_registerPointerMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block([candidate pointerValue]);
    }]);
}

static __autoreleasing id* mck_matchObjectPointer(BOOL(^block)(id* candidate)) {
    NSCParameterAssert(block != nil);
    return (__autoreleasing id *)mck_registerPointerMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {
        return block((__autoreleasing id *)[candidate pointerValue]);
    }]);
}

#define mck_matchStruct(structType, matcherBlock) mck_registerStructMatcher([MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {\
                                                    structType val; [candidate getValue:&val]; BOOL(^block)(structType) = matcherBlock;\
                                                    return block(val); }], structType)


#ifndef MOCK_DISABLE_NICE_SYNTAX
static id matchObject(BOOL(^block)(id candidate)) { return mck_matchObject(block); }
static char matchInt(BOOL(^block)(int64_t candidate)) { return mck_matchInt(block); }
static char matchUnsignedInt(BOOL(^block)(uint64_t candidate)) { return mck_matchUnsignedInt(block); }
static float matchFloat(BOOL(^block)(float candidate)) { return mck_matchFloat(block); }
static double matchDouble(BOOL(^block)(double candidate)) { return mck_matchDouble(block); }
static BOOL matchBool(BOOL(^block)(BOOL candidate)) { return mck_matchBool(block); }
static char* matchCString(BOOL(^block)(char* candidate)) { return mck_matchCString(block); }
static SEL matchSelector(BOOL(^block)(SEL candidate)) { return mck_matchSelector(block); }
static void* matchPointer(BOOL(^block)(void* candidate)) { return mck_matchPointer(block); }
static __autoreleasing id* matchObjectPointer(BOOL(^block)(id* candidate)) { return mck_matchObjectPointer(block); }
#define matchStruct(structType, matcherBlock) mck_matchStruct(structType, matcherBlock)
#endif
