//
//  RGMockSyntax.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


id mock_classMock(Class cls);
id mock_spy(id<NSObject> object);

id mock_verify_location(id mock, const char *fileName, int lineNumber);
#define mock_verify(_mock_) mock_verify_location(_mock_, __FILE__, __LINE__)


// Nice syntax
#define classMock(...) mock_classMock(__VA_ARGS__)
#define spy(...) mock_spy(__VA_ARGS__)

#define verify(...) mock_verify(__VA_ARGS__)
