//
//  OGCoreDataStackValueMapping.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGCoreDataStackCommon.h"

@protocol OGCoreDataStackValueMapping <NSObject>
@optional

/**
 Maps key between destination object and source object.
 @param destination The object should be populated with values.
 @param source The dictionary that contains values before mapping.
 @param sourceKey The key in the source.
 @return The source object keypath that matches the destinationKeyPath.
 */
- (NSString *)og_mappedKeyForDestination:(NSManagedObject *)destination source:(NSDictionary *)source sourceKey:(NSString *)sourceKey;

/**
 Maps values between destination object and source object.
 @param value Value from the source object.
 @param source The dictionary that contains values before mapping.
 @param destination The object should be populated with values.
 @param destinationKey The keypath that should be populated.
 @return The mapped value to store in the destination object.
 */
- (id)og_mappedValue:(id)value fromSource:(NSDictionary *)source sourceKey:(NSString *)sourceKey destination:(NSManagedObject *)destination destinationKey:(NSString *)destinationKey;

@end
