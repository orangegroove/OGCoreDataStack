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
	NSString* uniqueIdAttributeName = self.uniqueIdAttributeName;
	
	NSParameterAssert(uniqueId);
	NSParameterAssert(uniqueIdAttributeName);
	NSParameterAssert(context);
	
	id object = [self fetchWithRequest:^(NSFetchRequest *request) {
		
		request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueIdAttributeName, uniqueId];
		
	} context:context].firstObject;
	
	if (!object && !allowNil) {
		
		object = [self createObjectInContext:context];
		[object setValue:uniqueId forKeyPath:uniqueIdAttributeName];
	}
	
	return object;
}

@end
