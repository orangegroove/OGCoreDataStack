//
//  OGCoreDataStackTestHelper.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 28/05/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

@import CoreData;

@interface OGCoreDataStackTestHelper : NSObject

+ (void)seedPeople:(NSInteger)count inContext:(NSManagedObjectContext *)context;
+ (void)deleteDataInContext:(NSManagedObjectContext *)context;

@end
