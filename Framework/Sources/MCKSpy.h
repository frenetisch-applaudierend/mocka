//
//  MCKSpy.h
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCKMockingContext;


id mck_createSpyForObject(id object, MCKMockingContext *context);
BOOL mck_objectIsSpy(id object);
