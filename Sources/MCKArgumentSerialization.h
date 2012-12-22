//
//  MCKArgumentSerialization.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Object Arguments

static inline id mck_encodeObjectArgument(id arg) {
    return arg;
}

static inline id mck_decodeObjectArgument(id serialized) {
    return serialized;
}


#pragma mark - Primitive Arguments

static inline id mck_encodeIntegerArgument(int64_t arg) {
    return @(arg);
}

static inline int64_t mck_decodeIntegerArgument(id serialized) {
    return [serialized longLongValue];
}
