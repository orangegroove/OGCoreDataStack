//
//  NSManagedObjectContext+OGCoreDataStack.m
//
//  Created by Jesper <jesper@orangegroove.net>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <objc/runtime.h>
#import "NSManagedObjectContext+OGCoreDataStack.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

static const void* kObserverKey = "OGCoreDataStackObserverKey";

@implementation NSManagedObjectContext (OGCoreDataStack)

#pragma mark - Lifecycle

+ (instancetype)newContextWithConcurrency:(OGCoreDataStackContextConcurrency)concurrency
{
	NSUInteger concurrencyType;
	
	switch (concurrency) {
		case OGCoreDataStackContextConcurrencyMainQueue:
			
			concurrencyType = NSMainQueueConcurrencyType;
			break;
			
		case OGCoreDataStackContextConcurrencyBackgroundQueue:
			
			concurrencyType = NSPrivateQueueConcurrencyType;
			break;
	}
	
	NSManagedObjectContext* context		= [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
	context.persistentStoreCoordinator	= NSPersistentStoreCoordinator.sharedPersistentStoreCoordinator;
	context.retainsRegisteredObjects	= YES;
	
	return context;
}

- (BOOL)save
{
	NSError* error	= nil;
	BOOL success	= [self save:&error];
	
	NSAssert(success, @"Save error: %@", error.localizedDescription);
	
	return success;
}

#pragma mark - Observing

- (void)observeSavesInContext:(NSManagedObjectContext *)context
{
	if ([self isObservingSavesInContext:context])
		return;
	
	__block id weakSelf				= self;
	NSString* key					= [NSString stringWithFormat:@"%p", context];
	NSMutableDictionary* observers	= objc_getAssociatedObject(self, kObserverKey);
	
	if (!observers) {
		
		observers = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, kObserverKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	observers[key] = [NSNotificationCenter.defaultCenter addObserverForName:NSManagedObjectContextDidSaveNotification object:context queue:nil usingBlock:^(NSNotification* note) {
		
		[weakSelf mergeChangesFromContextDidSaveNotification:note];
	}];
}

- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context
{
	NSMutableDictionary* observers	= objc_getAssociatedObject(self, kObserverKey);
	NSString* key					= [NSString stringWithFormat:@"%p", context];
	id observer						= key.length? observers[key] : nil;
	
	if (observer) {
		
		[NSNotificationCenter.defaultCenter removeObserver:observer];
		[observers removeObjectForKey:key];
	}
}

- (BOOL)isObservingSavesInContext:(NSManagedObjectContext *)context
{
	NSMutableDictionary* observers	= objc_getAssociatedObject(self, kObserverKey);
	NSString* key					= [NSString stringWithFormat:@"%p", context];
	
	return key.length && observers[key];
}

#pragma mark - Operations

- (void)performBlock:(void (^)(NSArray *))block passObjects:(NSArray *)objects
{
	NSMutableArray* objectIDs = [NSMutableArray arrayWithCapacity:objects.count];
	
	for (NSManagedObject* object in objects)
		[objectIDs addObject:object.objectID];
	
	[self performBlock:^{
		
		NSMutableArray* passedObjects = [NSMutableArray array];
		
		for (NSManagedObjectID* objectID in objectIDs) {
			
			NSError* error			= nil;
			NSManagedObject* object = [self existingObjectWithID:objectID error:&error];
			
			NSAssert(!error, @"Error passing object with ID: %@", objectID.URIRepresentation.absoluteString);
			
			if (object)
				[passedObjects addObject:object];
		}
		
		block([NSArray arrayWithArray:passedObjects]);
	}];
}

- (void)performBlockAndWait:(void (^)(NSArray *))block passObjects:(NSArray *)objects
{
	NSMutableArray* objectIDs = [NSMutableArray arrayWithCapacity:objects.count];
	
	for (NSManagedObject* object in objects)
		[objectIDs addObject:object.objectID];
	
	[self performBlockAndWait:^{
		
		NSMutableArray* passedObjects = [NSMutableArray array];
		
		for (NSManagedObjectID* objectID in objectIDs) {
			
			NSError* error			= nil;
			NSManagedObject* object = [self existingObjectWithID:objectID error:&error];
			
			NSAssert(!error, @"Error passing object with ID: %@", objectID.URIRepresentation.absoluteString);
			
			if (object)
				[passedObjects addObject:object];
		}
		
		block([NSArray arrayWithArray:passedObjects]);
	}];
}

#pragma mark - Entities

- (id)createObjectForEntity:(Class)entity
{
	return [NSEntityDescription insertNewObjectForEntityForName:[entity entityName] inManagedObjectContext:self];
}

- (NSArray *)createObjectsForEntity:(Class)entity withPopulationDictionaries:(NSArray *)dictionaries avoidDuplicates:(BOOL)avoidDuplicates
{
	if (!dictionaries.count)
		return @[];
	
	NSMutableArray* objects					= [NSMutableArray array];
	NSMutableArray* translatedDictionaries	= _ogTranslatedPopulationDictionaries(entity, dictionaries);
	
	if (avoidDuplicates) {
		
		NSString* idAttributeName = [entity uniqueIdAttributeName];
		
		if (idAttributeName) {
			
			NSMutableArray* ids = _ogIdsForEntity(entity, translatedDictionaries);
			
			[objects addObjectsFromArray:[self fetchFromEntity:entity withRequest:^(NSFetchRequest *request) {
				
				request.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", idAttributeName, ids];
			}]];
			
			for (id object in objects) {
				
				id idAttributeValue				= [object valueForKey:idAttributeName];
				NSMutableDictionary* dictionary	= _ogPopulationDictionaryMatchingId(entity, translatedDictionaries, idAttributeValue);
				
				[translatedDictionaries removeObject:dictionary];
				[object populateWithDictionary:dictionary options:OGCoreDataStackPopulationOptionSkipTranslation];
			}
		}
	}
	
	for (NSMutableDictionary* dictionary in translatedDictionaries) {
		
		NSManagedObject* object = [self createObjectForEntity:entity];
		
		[object populateWithDictionary:dictionary options:OGCoreDataStackPopulationOptionSkipTranslation];
		[objects addObject:object];
	}
	
	return [NSArray arrayWithArray:objects];
}

- (NSArray *)fetchFromEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[entity entityName]];
	NSError* error			= nil;
	
	if (block)
		block(request);
	
	NSArray* objects = [self executeFetchRequest:request error:&error];
	
	NSAssert(!error, @"Fetch Error: %@", error.localizedDescription);
	
	return objects;
}

- (NSUInteger)countEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block
{
	NSFetchRequest* request	= [NSFetchRequest fetchRequestWithEntityName:[entity entityName]];
	NSError* error			= nil;
	
	if (block)
		block(request);
	
	request.sortDescriptors	= nil;
	NSUInteger count		= [self countForFetchRequest:request error:&error];
	
	NSAssert(count != NSNotFound, @"Count Error: %@", error.localizedDescription);
	
	return count;
}

- (void)deleteFromEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block
{
	NSArray* objects = [self fetchFromEntity:entity withRequest:^(NSFetchRequest *request) {
		
		if (block)
			block(request);
		
		request.returnsObjectsAsFaults				= YES;
		request.includesPropertyValues				= NO;
		request.sortDescriptors						= nil;
		request.relationshipKeyPathsForPrefetching	= nil;
	}];
	
	[self deleteObjects:objects];
}

- (void)deleteObjects:(NSArray *)objects
{
	for (NSManagedObject* object in objects)
		[self deleteObject:object];
}

- (BOOL)obtainPermanentIDsForObjects:(NSArray *)objects
{
	NSError* error	= nil;
	BOOL success	= [self obtainPermanentIDsForObjects:objects error:&error];
	
	NSAssert(success, @"ObtainPermanentIDs Error: %@", error.localizedDescription);
	
	return success;
}

@end
