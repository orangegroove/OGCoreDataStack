//
//  OGManagedObject+OGCoreDataStackUniqueId.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 31/03/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGManagedObject+OGCoreDataStackUniqueId.h"

@implementation OGManagedObject (OGCoreDataStackUniqueId)

#pragma mark - Lifecycle

+ (NSString *)uniqueIdAttributeName
{
	return nil;
}

#pragma mark - Inserting

+ (id)objectWithUniqueId:(id)uniqueId allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context
{
	return [self objectsWithUniqueIds:@[uniqueId] allowNil:allowNil context:context].firstObject;
}

+ (NSArray *)objectsWithUniqueIds:(NSArray *)uniqueIds allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context
{
	NSString* uniqueIdAttributeName = self.uniqueIdAttributeName;
	
	NSParameterAssert(uniqueIds.count);
	NSParameterAssert(uniqueIdAttributeName);
	NSParameterAssert(context);
	
	NSMutableArray* objects = [NSMutableArray arrayWithArray:[self fetchWithRequest:^(NSFetchRequest *request) {
		
		request.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", uniqueIdAttributeName, uniqueIds];
		
	} context:context]];
	
	if (!allowNil && objects.count != uniqueIds.count) {
		
		NSMutableArray* missingIds = [NSMutableArray arrayWithArray:uniqueIds];
		[missingIds removeObjectsInArray:[objects valueForKey:uniqueIdAttributeName]];
		
		for (id uniqueId in missingIds) {
			
			id object = [self createObjectInContext:context];
			
			[object setValue:uniqueId forKeyPath:uniqueIdAttributeName];
			[objects addObject:object];
		}
	}
	
	return [NSArray arrayWithArray:objects];
}

@end
