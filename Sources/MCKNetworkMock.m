//
//  MCKNetworkMock.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkMock.h"
#import "MCKNetworkMock_Private.h"
#import "MCKMockObject.h"
#import "MCKNetworkRequestMatcher.h"
#import "MCKMockingContext.h"
#import "NSInvocation+MCKArgumentHandling.h"


@interface MCKNetworkMock ()

@property (nonatomic, readonly) MCKMockingContext *mockingContext;

@end

@implementation MCKNetworkMock

#pragma mark - Initialization

+ (void)initialize {
    if (!(self == [MCKNetworkMock class])) {
        return;
    }
    
    // Check that OHHTTPStubs is available
    if (NSClassFromString(@"OHHTTPStubs") == nil) {
        NSLog(@"****************************************************************");
        NSLog(@"* Mocka could not find the OHHTTPStubs library                 *");
        NSLog(@"* Make sure you have the library linked in your testing target *");
        NSLog(@"****************************************************************");
        abort();
    }
}

+ (instancetype)sharedMock {
    static dispatch_once_t onceToken;
    static MCKNetworkMock *sharedMock = nil;
    dispatch_once(&onceToken, ^{
        sharedMock = [[self alloc] init];
    });
    return sharedMock;
}

- (instancetype)initWithMockingContext:(MCKMockingContext *)context {
    if ((self = [super init])) {
        _customMockingContext = context;
        _stubsDescriptor = [self setupStubsDescriptor];
    }
    return self;
}

- (instancetype)init {
    return [self initWithMockingContext:nil];
}

- (id<OHHTTPStubsDescriptor>)setupStubsDescriptor {
    __weak typeof(self) weakSelf = self;
    return [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [weakSelf hasResponseForRequest:request];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [weakSelf responseForRequest:request];
    }];
}

- (void)dealloc {
    [OHHTTPStubs removeStub:self.stubsDescriptor];
}


#pragma mark - Getting the Context

- (MCKMockingContext *)mockingContext {
    return (self.customMockingContext ?: [MCKMockingContext currentContext]); // used for testing
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
    return [self.mockingContext isInvocationStubbed:[self handlerInvocationForRequest:request]];
}

- (OHHTTPStubsResponse *)responseForRequest:(NSURLRequest *)request {
    NSInvocation *invocation = [self handlerInvocationForRequest:request];
    [self.mockingContext handleInvocation:invocation]; // process the stubbings
    return [self responseForReturnValue:[invocation objectReturnValue]];
}

- (OHHTTPStubsResponse *)responseForReturnValue:(id)value {
    return value;
}


#pragma mark - Mock Method

- (id)handleNetworkRequest:(NSURLRequest *)request {
    return nil; // return nil if not stubbed, to indicate that the request should go to the network
}

@end
