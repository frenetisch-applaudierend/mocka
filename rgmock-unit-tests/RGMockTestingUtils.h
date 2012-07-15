//
//  RGMockTestingUtils.h
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#define AssertDoesNotFail(...) @try { __VA_ARGS__ ; } @catch(id exception) { STFail(@"Failed with exception: %@", exception); }
#define AssertFails(...) @try { __VA_ARGS__ ; STFail(@"This should have failed"); } @catch(id ignored) {}
