//
//  NSManagedObject+OGCoreDataStackValueMapping.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "NSManagedObject+OGCoreDataStackValueMapping.h"
#import "OGCoreDataStackValueMapping.h"

@implementation NSManagedObject (OGCoreDataStackValueMapping)

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

@end
