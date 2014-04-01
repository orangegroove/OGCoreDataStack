//
//  OGManagedObject+OGCoreDataStackUniqueId.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 31/03/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGManagedObject.h"

@interface OGManagedObject (OGCoreDataStackUniqueId)

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 The attribute name that represents the unique id attribute for this entity.
 @return The unique id key. Defaults to nil (no id attribute).
 @note This is intended to be used for synchronizing data with relational databases (such as data from web services). To easily import such data use the NSManagedObjectContext method createObjectsForEntity:withPopulationDictionaries:options:.
 */
+ (NSString *)uniqueIdAttributeName;

#pragma mark - Inserting

/**
 Inserts a new object into a context.
 @param uniqueId The unique id of the object to return.
 @param allowNil If false, the object is inserted into the context if it doesn't exist
 @param context The context.
 @return The newly created object.
 */
+ (id)objectWithUniqueId:(id)uniqueId allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context;

/**
 Inserts new object into a context.
 @param uniqueIds An array of unique id's of the objects to return.
 @param allowNil If false, the objects are inserted into the context if they don't exist
 @param context The context.
 @return The newly created objects.
 @note The returned objects will have an undefined order.
 */
+ (NSArray *)objectsWithUniqueIds:(NSArray *)uniqueIds allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context;

@end
