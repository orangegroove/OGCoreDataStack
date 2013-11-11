//
//  NSPersistentStoreCoordinator+OGCoreDataStack.m
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

#import "NSPersistentStoreCoordinator+OGCoreDataStack.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

static dispatch_once_t					_ogCoreDataStackToken						= 0;
static NSPersistentStoreCoordinator*	_ogCoreDataStackPersistentStoreCoordinator	= nil;
static NSManagedObjectModel*			_ogCoreDataStackManagedObjectModel			= nil;

@implementation NSPersistentStoreCoordinator (OGModelStack)

#pragma mark - Lifecycle

+ (instancetype)sharedPersistentStoreCoordinator
{
	[self setupWithStoreType:nil options:nil];
	
	return _ogCoreDataStackPersistentStoreCoordinator;
}

+ (void)setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options
{
	dispatch_once(&_ogCoreDataStackToken, ^{
		
		NSString* coordinatorStoreType		= storeType;
		NSDictionary* coordinatorOptions	= options;
		
		if (!coordinatorStoreType)
			coordinatorStoreType = NSSQLiteStoreType;
		
		if (!coordinatorOptions)
			coordinatorOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
		
		NSError* error								= nil;
		NSManagedObjectModel* model					= [[NSManagedObjectModel alloc] initWithContentsOfURL:_ogMomdURL()];
		_ogCoreDataStackPersistentStoreCoordinator	= [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		
		if (![_ogCoreDataStackPersistentStoreCoordinator addPersistentStoreWithType:coordinatorStoreType configuration:nil URL:_ogSQLiteURL() options:coordinatorOptions error:&error]) {
#ifdef DEBUG
			OGCoreDataStackLog(@"Add Persistent Store Error: %@", error.localizedDescription);
			OGCoreDataStackLog(@"Missing migration? %@", ![error.userInfo[@"sourceModel"] isEqual:error.userInfo[@"destinationModel"]] ? @"YES" : @"NO");
#endif
		}
	});
}

+ (BOOL)reset
{
	if (!_ogCoreDataStackPersistentStoreCoordinator.persistentStores.count)
		return YES;
	
	NSError* error	= nil;
	NSString* path	= _ogSQLiteURL().path;
	
	if (![_ogCoreDataStackPersistentStoreCoordinator removePersistentStore:_ogCoreDataStackPersistentStoreCoordinator.persistentStores[0] error:&error]) {
#ifdef DEBUG
		OGCoreDataStackLog(@"Remove Persistent Store Error: %@", error.localizedDescription);
#endif
		return NO;
	}
	
	if (![NSFileManager.defaultManager fileExistsAtPath:path])
		return YES;
	
	if (![NSFileManager.defaultManager removeItemAtPath:path error:&error]) {
#ifdef DEBUG
		OGCoreDataStackLog(@"Remove Persistent Store File Error: %@", error.localizedDescription);
#endif
		return NO;
	}
	
	_ogCoreDataStackToken						= 0;
	_ogCoreDataStackPersistentStoreCoordinator	= nil;
	_ogCoreDataStackManagedObjectModel			= nil;
	
	return YES;
}

@end
