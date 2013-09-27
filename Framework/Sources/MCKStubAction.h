//
//  MCKStubAction.h
//  mocka
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKStubAction <NSObject>

- (void)performWithInvocation:(NSInvocation *)invocation;

@end


extern void _mck_addStubAction(id<MCKStubAction> action);
