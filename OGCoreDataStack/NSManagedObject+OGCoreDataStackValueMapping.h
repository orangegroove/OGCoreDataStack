//
//  NSManagedObject+OGCoreDataStackValueMapping.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGCoreDataStackCommon.h"

@protocol OGCoreDataStackValueMapping;

@interface NSManagedObject (OGCoreDataStackValueMapping)

/**
 Maps values from source object.
 @param sourceObject The dictionary which contains the values to map.
 @param mapper Mapping configuration.
 */
- (void)og_mapAttributeValuesFromSource:(NSDictionary *)dictionary mapper:(id<OGCoreDataStackValueMapping>)mapper;

@end
