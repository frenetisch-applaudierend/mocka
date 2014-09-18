//
//  MCKWeakRef.h
//  mocka
//
//  Created by Markus Gasser on 11.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCKWeakRef : NSObject

+ (instancetype)weakRefForObject:(id)object;
- (instancetype)initWithObject:(id)object;

@property (nonatomic, readonly, weak) id object;

@end
