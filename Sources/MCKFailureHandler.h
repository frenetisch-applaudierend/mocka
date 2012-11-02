//
//  MCKFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKFailureHandler <NSObject>

- (void)handleFailureInFile:(NSString *)file atLine:(NSUInteger)line withReason:(NSString *)reason;

@end
