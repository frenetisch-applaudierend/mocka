//
//  RGMockStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@protocol RGMockStubAction <NSObject>

@end

static BOOL mock_record_stub_action(id<RGMockStubAction> action) {
    return YES;
}
