//
//  OGManagedObjectContext.m
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

#import "OGManagedObjectContext.h"
#import "OGCoreDataStackCore.h"
#import "OGCoreDataStackPrivate.h"

@interface OGManagedObjectContext ()

@property (strong, nonatomic) NSMutableDictionary* observers;

- (NSString *)observerKeyForContext:(NSManagedObjectContext *)context;

@end
@implementation OGManagedObjectContext

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
	
	OGManagedObjectContext* context		= [[self alloc] initWithConcurrencyType:concurrencyType];
	context.persistentStoreCoordinator	= OGPersistentStoreCoordinator.sharedPersistentStoreCoordinator;
	
	return context;
}

- (OGCoreDataStackContextConcurrency)contextConcurrency
{
	switch (self.concurrencyType) {
		case NSMainQueueConcurrencyType:
			return OGCoreDataStackContextConcurrencyMainQueue;
		case NSPrivateQueueConcurrencyType:
			return OGCoreDataStackContextConcurrencyBackgroundQueue;
		default:
			return UINT16_MAX;
	}
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
	NSParameterAssert(context);
	
	if ([self isObservingSavesInContext:context])
		return;
	
	__block id weakSelf	= self;
	NSString* key		= [self observerKeyForContext:context];
	self.observers[key]	= [NSNotificationCenter.defaultCenter addObserverForName:NSManagedObjectContextDidSaveNotification object:context queue:nil usingBlock:^(NSNotification* note) {
		
		[weakSelf mergeChangesFromContextDidSaveNotification:note];
	}];
}

- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	NSString* key	= [self observerKeyForContext:context];
	id observer		= key.length? self.observers[key] : nil;
	
	if (observer) {
		
		[NSNotificationCenter.defaultCenter removeObserver:observer];
		[self.observers removeObjectForKey:key];
	}
}

- (BOOL)isObservingSavesInContext:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	NSString* key = [self observerKeyForContext:context];
	
	return key.length && self.observers[key];
}

#pragma mark - Operations

- (void)performBlock:(void (^)(NSArray *))block passObjects:(NSArray *)objects
{
	NSParameterAssert(block);
	
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
	NSParameterAssert(block);
	
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

#pragma mark - Private

- (NSString *)observerKeyForContext:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	return [NSString stringWithFormat:@"%p", context];
}

#pragma mark - Properties

- (NSMutableDictionary *)observers
{
	if (_observers)
		return _observers;
	
	_observers = [NSMutableDictionary dictionary];
	
	return _observers;
}

@end
