//
//  NSManagedObject+OGCoreDataStackValueMapping.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGCoreDataStackCommon.h"
#import "NSManagedObject+OGCoreDataStackUniqueId.h"

@protocol OGCoreDataStackValueMapping;

@interface NSManagedObject (OGCoreDataStackValueMapping)

/**
 Maps values from source object.
 @param dictionary The dictionary which contains the values to map.
 @param mapper Mapping configuration.
 @note Mapping is possible without a mapper object.
 */
- (void)og_mapAttributeValuesFromSource:(NSDictionary *)dictionary mapper:(id<OGCoreDataStackValueMapping>)mapper;

/**
 Creates a managed object from source object.
 @param dictionary The source object.
 @param context The context in which to create the object.
 @param respectUniqueId Checks the persistent store for existing object before creation. If no id is found in the source, no object is created.
 @return The fetched or created object, populated with values from the source.
 */
+ (instancetype)og_objectFromSource:(NSDictionary *)dictionary mapper:(id<OGCoreDataStackValueMapping>)mapper context:(NSManagedObjectContext *)context respectUniqueId:(BOOL)respectUniqueId;

/**
 Creates managed objects from source objects.
 @param dictionaries The source objects.
 @param context The context in which to create the objects.
 @param respectUniqueId Checks the persistent store for existing objects before creation. If no id is found in the source, no object is created.
 @return The fetched or created objects, populated with values from the source.
 */
+ (NSArray *)og_objectsFromSources:(id<NSFastEnumeration>)dictionaries mapper:(id<OGCoreDataStackValueMapping>)mapper context:(NSManagedObjectContext *)context respectUniqueId:(BOOL)respectUniqueId;

@end
