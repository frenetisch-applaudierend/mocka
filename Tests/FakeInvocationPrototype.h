//
//  FakeInvocationPrototype.h
//  mocka
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import <Mocka/MCKInvocationPrototype.h>


@interface FakeInvocationPrototype : MCKInvocationPrototype

+ (instancetype)dummy;
+ (instancetype)thatAlwaysMatches;
+ (instancetype)thatNeverMatches;

+ (instancetype)withImplementation:(BOOL(^)(NSInvocation *candidate))matcher;
- (instancetype)initWithMatcherImplementation:(BOOL(^)(NSInvocation *candidate))matcher;

@property (nonatomic, copy) BOOL(^matcherImplementation)(NSInvocation*);

@end
