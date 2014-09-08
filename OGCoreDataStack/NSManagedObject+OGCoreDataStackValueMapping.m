//
//  NSManagedObject+OGCoreDataStackValueMapping.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "NSManagedObject+OGCoreDataStackValueMapping.h"
#import "OGCoreDataStackValueMapping.h"
#import "OGCoreDataStackCore.h"

@implementation NSManagedObject (OGCoreDataStackValueMapping)

#pragma mark - Public

- (void)og_mapAttributeValuesFromSource:(NSDictionary *)dictionary mapper:(id<OGCoreDataStackValueMapping>)mapper
{
    NSParameterAssert(dictionary);
    
    if (!dictionary)
    {
        return;
    }
    
    BOOL transformKey   = [mapper respondsToSelector:@selector(og_mappedKeyForDestination:source:sourceKey:)];
    BOOL transformValue = [mapper respondsToSelector:@selector(og_mappedValue:fromSource:sourceKey:destination:destinationKey:)];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        
        NSAssert([key isKindOfClass:NSString.class], @"Dictionary keys must be NSString.");
        
        NSString* destinationKey = transformKey? [mapper og_mappedKeyForDestination:self source:dictionary sourceKey:key] : key;
        
        id value = dictionary[key];
        
        if (transformValue)
        {
            value = [mapper og_mappedValue:value fromSource:dictionary sourceKey:key destination:self destinationKey:destinationKey];
        }
        
        [self setValue:value forKey:destinationKey];
    }];
}

+ (instancetype)og_objectFromSource:(NSDictionary *)dictionary mapper:(id<OGCoreDataStackValueMapping>)mapper context:(NSManagedObjectContext *)context respectUniqueId:(BOOL)respectUniqueId
{
    if (respectUniqueId)
    {
        return [self _ogObjectsWithUniqueIdFromSources:@[dictionary] mapper:mapper context:context].firstObject;
    }
    else
    {
        id object = [self og_createObjectInContext:context];
        [object og_mapAttributeValuesFromSource:dictionary mapper:mapper];
        
        return object;
    }
}

+ (NSArray *)og_objectsFromSources:(id<NSFastEnumeration>)dictionaries mapper:(id<OGCoreDataStackValueMapping>)mapper context:(NSManagedObjectContext *)context respectUniqueId:(BOOL)respectUniqueId
{
    if (respectUniqueId)
    {
        return [self _ogObjectsWithUniqueIdFromSources:dictionaries mapper:mapper context:context];
    }
    else
    {
        NSMutableArray* mutableObjects = [NSMutableArray array];
        
        for (NSDictionary* dictionary in dictionaries)
        {
            id object = [self og_objectFromSource:dictionary mapper:mapper context:context respectUniqueId:NO];
            
            if (object)
            {
                [mutableObjects addObject:object];
            }
        }
        
        return [NSArray arrayWithArray:mutableObjects];
    }
}

#pragma mark - Private

+ (NSArray *)_ogObjectsWithUniqueIdFromSources:(id<NSFastEnumeration>)dictionaries mapper:(id<OGCoreDataStackValueMapping>)mapper context:(NSManagedObjectContext *)context
{
    NSString* idAttribute   = [self og_uniqueIdAttributeName];
    NSMutableSet* uniqueIds = [NSMutableSet set];
    NSArray* objects;
    
    for (NSDictionary* dictionary in dictionaries)
    {
        NSString* idKey = [mapper og_mappedKeyForDestination:self source:dictionary sourceKey:idAttribute];
        id uniqueId     = idKey? dictionary[idKey] : nil;
        
        if (uniqueId)
        {
            [uniqueIds addObject:uniqueId];
        }
    }
    
    objects = [self og_objectsWithUniqueIds:uniqueIds allowNil:NO context:context];
    
    for (id object in objects)
    {
        id uniqueId = [object og_uniqueIdAttribute];
        
        if (uniqueId)
        {
            for (NSDictionary* dictionary in dictionaries)
            {
                NSString* idKey = [mapper og_mappedKeyForDestination:object source:dictionary sourceKey:idAttribute];
                id value        = dictionary[idKey];
                
                if ([value isEqual:uniqueId])
                {
                    [object og_mapAttributeValuesFromSource:dictionary mapper:mapper];
                    break;
                }
            }
        }
    }
    
    return objects;
}

@end
