//
//  RGMockFailureHandler.h
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RGMockFailureHandler <NSObject>

- (void)handleFailureInFile:(NSString *)file atLine:(NSUInteger)line withReason:(NSString *)reason;

@end
