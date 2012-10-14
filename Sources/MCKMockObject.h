//
//  MCKMockObject.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKMockingContext;


@interface MCKMockObject : NSObject

#pragma mark - Initialization

+ (id)mockWithContext:(MCKMockingContext *)context classAndProtocols:(NSArray *)sourceList;
- (id)initWithContext:(MCKMockingContext *)context classAndProtocols:(NSArray *)sourceList;

@end


// Mocking Syntax
#define mck_mock(cls, ...) [MCKMockObject mockWithContext:mck_updatedContext() classAndProtocols:@[ cls, __VA_ARGS__ ]]
#define mck_mockClass(cls) mck_mock([cls class])
#define mck_mockProtocol(prt) mck_mock(@protocol(prt))

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define mock(cls, ...) mck_mock(cls, __VA_ARGS__)
#define mockClass(cls) mck_mockClass(cls)
#define mockProtocol(prt) mck_mockProtocol(prt)
#endif
