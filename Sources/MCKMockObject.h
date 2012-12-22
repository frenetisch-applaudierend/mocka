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
- (id)initWithContext:(MCKMockingContext *)context mockedClass:(Class)mockedClass mockedProtocols:(NSArray *)mockedProtocols;


#pragma mark - Getting information about the mock

@property (nonatomic, readonly) NSArray *mck_mockedEntites;

@end


// Mocking Syntax
#define mck_mock(cls, ...) [MCKMockObject mockWithContext:mck_updatedContext() classAndProtocols:@[ cls, __VA_ARGS__ ]]
#define mck_mockForClass(cls) (cls *)mck_mock([cls class])
#define mck_mockForProtocol(prt) (id<prt>)mck_mock(@protocol(prt))

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define mock(cls, ...) mck_mock(cls, __VA_ARGS__)
#define mockForClass(cls) mck_mockForClass(cls)
#define mockForProtocol(prt) mck_mockForProtocol(prt)
#endif
