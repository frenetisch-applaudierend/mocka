//
//  MCKFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKFailureHandler <NSObject>

@property (nonatomic, readonly, copy)   NSString *fileName;
@property (nonatomic, readonly, assign) NSUInteger lineNumber;

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber;

- (void)handleFailureWithReason:(NSString *)reason;

@end
