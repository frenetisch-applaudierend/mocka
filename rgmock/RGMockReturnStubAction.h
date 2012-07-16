//
//  RGMockReturnStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockStubAction.h"


@interface RGMockReturnStubAction : NSObject <RGMockStubAction>

@end


#define mock_returnValue(val) mock_record_stub_action(nil)

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define returnValue(val) mock_returnValue(val)
#endif
