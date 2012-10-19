//
//  NSInvocation+MCKArgumentHandling.h
//  mocka
//
//  Created by Markus Gasser on 19.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (MCKArgumentHandling)

- (NSInteger)mck_integerArgumentAtEffectiveIndex:(NSUInteger)index;
- (NSUInteger)mck_unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index;


#ifndef MOCK_DISABLE_NICE_SYNTAX

- (NSInteger)integerArgumentAtEffectiveIndex:(NSUInteger)index;
- (NSUInteger)unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index;

#endif

@end
