//
//  NSInvocation+MCKArgumentHandling.h
//  mocka
//
//  Created by Markus Gasser on 19.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSInvocation (MCKArgumentHandling)

- (id)mck_objectArgumentAtEffectiveIndex:(NSUInteger)index;
- (NSInteger)mck_integerArgumentAtEffectiveIndex:(NSUInteger)index;
- (NSUInteger)mck_unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index;

- (void)mck_setObjectReturnValue:(id)value;

@end


#ifndef MOCK_DISABLE_NICE_SYNTAX
@interface NSInvocation (MCKArgumentHandling_NiceSyntax)

- (id)objectArgumentAtEffectiveIndex:(NSUInteger)index;
- (NSInteger)integerArgumentAtEffectiveIndex:(NSUInteger)index;
- (NSUInteger)unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index;

- (void)setObjectReturnValue:(id)value;

@end
#endif
