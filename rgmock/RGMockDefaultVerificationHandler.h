//
//  RGMockDefaultVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockVerificationHandler.h"


@interface RGMockDefaultVerificationHandler : NSObject <RGMockVerificationHandler>

+ (id)defaultHandler;

@end
