//
//  RGMockArgumentMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int AnyIntMagicNumber = 1010414321;
#define mock_anyInt() AnyIntMagicNumber
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define anyInt() mock_anyInt()
#endif