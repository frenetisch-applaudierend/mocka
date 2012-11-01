//
//  MCKFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKFailureHandler <NSObject>

#pragma mark - Providing

@property (nonatomic, readonly, copy)   NSString   *fileName;
@property (nonatomic, readonly, assign) NSUInteger  lineNumber;

- (void)updateCurrentFileName:(NSString *)file andLineNumber:(NSUInteger)line;

- (void)handleFailureWithReason:(NSString *)reason;

@end
