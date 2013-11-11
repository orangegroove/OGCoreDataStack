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

+ (instancetype)contextWithConcurrency:(OGCoreDataStackContextConcurrency)concurrency
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
	
#ifdef DEBUG
	if (!success)
		OGCoreDataStackLog(@"Save Error: %@", error.localizedDescription);
#endif
	
	return success;
}

#pragma mark - Observing

- (void)observeSavesInContext:(NSManagedObjectContext *)context
{
	__block id weakSelf = self;
	id observer			= [NSNotificationCenter.defaultCenter addObserverForName:NSManagedObjectContextDidSaveNotification object:context queue:nil usingBlock:^(NSNotification* note) {
		
		[weakSelf mergeChangesFromContextDidSaveNotification:note];
	}];
	
	objc_setAssociatedObject(self, kObserverKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context
{
	id observer = objc_getAssociatedObject(self, kObserverKey);
	
	if (observer) {
		
		objc_setAssociatedObject(self, kObserverKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[NSNotificationCenter.defaultCenter removeObserver:observer];
	}
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
			
#ifdef DEBUG
			OGCoreDataStackLog(@"Error passing object with ID: %@", objectID.URIRepresentation.absoluteString);
#endif
			
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
			
#ifdef DEBUG
			OGCoreDataStackLog(@"Error passing object with ID: %@", objectID.URIRepresentation.absoluteString);
#endif
			
			if (object)
				[passedObjects addObject:object];
		}
		
		block([NSArray arrayWithArray:passedObjects]);
	}];
}

#pragma mark - Entities

- (NSArray *)fetchEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[entity entityName]];
	NSError* error			= nil;
	
	if (block)
		block(request);
	
	NSArray* objects = [self executeFetchRequest:request error:&error];
	
#ifdef DEBUG
	if (error)
		OGCoreDataStackLog(@"Fetch Error: %@", error.localizedDescription);
#endif
	
	return objects;
}

- (NSUInteger)countEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block
{
	NSFetchRequest* request	= [NSFetchRequest fetchRequestWithEntityName:[entity entityName]];
	NSError* error			= nil;
	
	if (block)
		block(request);
	
	NSUInteger count = [self countForFetchRequest:request error:&error];
	
#ifdef DEBUG
	if (count == NSNotFound)
		OGCoreDataStackLog(@"Count Error: %@", error.localizedDescription);
#endif
	
	return count;
}

- (void)deleteEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block
{
	NSArray* objects = [self fetchEntity:entity withRequest:^(NSFetchRequest *request) {
		
		if (block)
			block(request);
		
		request.includesPropertyValues	= NO;
		request.sortDescriptors			= nil;
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
	
#ifdef DEBUG
	if (!success)
		OGCoreDataStackLog(@"ObtainPermanentIDs Error: %@", error.localizedDescription);
#endif
	
	return success;
}

#pragma mark - Private

@end
