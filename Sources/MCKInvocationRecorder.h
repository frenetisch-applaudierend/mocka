//
//  MCKInvocationRecorder.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKInvocationRecorderDelegate;


@interface MCKInvocationRecorder : NSObject

#pragma mark - Configuration

@property (nonatomic, weak) id<MCKInvocationRecorderDelegate> delegate;


#pragma mark - Managing Invocations

@property (nonatomic, readonly) NSArray *recordedInvocations;

- (NSInvocation *)invocationAtIndex:(NSUInteger)index;

- (void)appendInvocation:(NSInvocation *)invocation;
- (void)insertInvocations:(NSArray *)invocations atIndex:(NSUInteger)index;

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes;
- (void)removeInvocationsInRange:(NSRange)range;

@end


@protocol MCKInvocationRecorderDelegate <NSObject>

- (void)invocationRecorder:(MCKInvocationRecorder *)recorded didRecordInvocation:(NSInvocation *)invocation;

@end
