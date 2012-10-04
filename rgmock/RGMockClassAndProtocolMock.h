//
//  RGClassMock.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RGMockContext;


@interface RGMockClassAndProtocolMock : NSObject

#pragma mark - Initialization

+ (id)mockWithContext:(RGMockContext *)context classAndProtocols:(NSArray *)sourceList;
- (id)initWithContext:(RGMockContext *)context classAndProtocols:(NSArray *)sourceList;

@end


// Mocking Syntax
#define mck_mock(cls, ...) [RGMockClassAndProtocolMock mockWithContext:mck_updatedContext() classAndProtocols:@[ cls, __VA_ARGS__ ]]

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define mock(cls, ...) mck_mock(cls, __VA_ARGS__)
#endif
