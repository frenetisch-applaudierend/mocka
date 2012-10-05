//
//  RGMockExceptionFailureHandler.h
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockFailureHandler.h"


extern NSString * const RGMockFileNameKey;
extern NSString * const RGMockLineNumberKey;

@interface RGMockExceptionFailureHandler : NSObject <RGMockFailureHandler>

@end
