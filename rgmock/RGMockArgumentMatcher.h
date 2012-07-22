//
//  RGMockArgumentMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RGMockArgumentMatcher <NSObject>

@end


// Mocking Syntax
#define mock_argMatching(m) m
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define argMatching(m) mock_argMatching((m))
#endif
