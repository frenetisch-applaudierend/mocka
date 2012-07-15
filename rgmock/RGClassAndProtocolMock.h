//
//  RGClassMock.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

@class RGMockingContext;


@interface RGClassAndProtocolMock : NSObject

#pragma mark - Initialization

+ (id)mockWithContext:(RGMockingContext *)context classAndProtocols:(NSArray *)sourceList;
- (id)initWithContext:(RGMockingContext *)context classAndProtocols:(NSArray *)sourceList;

@end


// Mocking Syntax
#define mock_mock(cls, ...) [RGClassAndProtocolMock mockWithContext:mock_current_context() classAndProtocols:@[ cls, __VA_ARGS__ ]]
#ifdef MOCK_SHORTHAND
#define mock(cls, ...) mock_mock(cls, __VA_ARGS__)
#endif
