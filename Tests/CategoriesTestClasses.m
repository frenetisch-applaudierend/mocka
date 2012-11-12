//
//  CategoriesTestClasses.m
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "CategoriesTestClasses.h"


#pragma mark - Needed Classes

@implementation CategoriesTestSuperclass
@end

@implementation CategoriesTestMockedClass
@end


#pragma mark - Categories

@implementation CategoriesTestMockedClass (CategoryOnMockedClass)

- (void)categoryMethodInMockedClass {
}

@end

@implementation CategoriesTestMockedClass (CategoryOnMockedClassSuperclass)

- (void)categoryMethodInMockedClassSuperclass {
}

@end

@implementation NSObject (CategoryOnNSObject)

- (void)categoryMethodInNSObject {
}

@end
