//
//  MCKNetworkMock.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkMock.h"
#import "MCKNetworkMock_Private.h"
#import "MCKNetworkRequestMatcher.h"
#import "MCKMockingContext.h"


@implementation MCKNetworkMock

#pragma mark - Initialization

+ (instancetype)sharedMock {
    static dispatch_once_t onceToken;
    static MCKNetworkMock *sharedMock = nil;
    dispatch_once(&onceToken, ^{
        sharedMock = [[self alloc] init];
    });
    return sharedMock;
}

- (instancetype)init {
    if ((self = [super init])) {
        __weak typeof(self) weakSelf = self;
        _stubDescriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [weakSelf hasResponseForRequest:request];
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [weakSelf responseForRequest:request];
        }];
    }
    return self;
}

- (void)dealloc {
    [OHHTTPStubs removeStub:self.stubDescriptor];
}


#pragma mark - Properties

- (MCKMockingContext *)mockingContext {
    return (_mockingContext ?: [MCKMockingContext currentContext]);
}


#pragma mark - Request Configuration

- (MCKNetworkActivity)GET {
    return ^(id urlParam) {
        NSURL *url = [self URLFromURLParameter:urlParam];
        MCKNetworkRequestMatcher *matcher =  [MCKNetworkRequestMatcher matcherForURL:url HTTPMethod:@"GET"];
        [self.mockingContext handleInvocation:[self handlerInvocationForRequest:matcher]];
        return matcher;
    };
}

- (NSURL *)URLFromURLParameter:(id)url {
    return ((url == nil || [url isKindOfClass:[NSURL class]]) ? url : [NSURL URLWithString:url]);
}

- (NSInvocation *)handlerInvocationForRequest:(id)request {
    NSMethodSignature *signature = [self methodSignatureForSelector:@selector(handleNetworkRequest:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = @selector(handleNetworkRequest:);
    [invocation setArgument:&request atIndex:2];
    return invocation;
}


#pragma mark - Getting Request Info

- (BOOL)hasResponseForRequest:(NSURLRequest *)request {
    return NO;
}

- (OHHTTPStubsResponse *)responseForRequest:(NSURLRequest *)request {
    return nil;
}


#pragma mark - Mock Method

- (id)handleNetworkRequest:(NSURLRequest *)request {
    return nil; // return nil if not stubbed, to indicate that the request should go to the network
}

@end
