//
//  CategoriesTestClasses.h
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Needed Classes

@interface CategoriesTestSuperclass : NSObject
@end

@interface CategoriesTestMockedClass : CategoriesTestSuperclass
@end


#pragma mark - Categories

@interface CategoriesTestMockedClass (CategoryOnMockedClass)

- (void)categoryMethodInMockedClass;

@end

@interface CategoriesTestMockedClass (CategoryOnMockedClassSuperclass)

- (void)categoryMethodInMockedClassSuperclass;

@end

@interface NSObject (CategoryOnNSObject)

- (void)categoryMethodInNSObject;

@end
