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

static dispatch_once_t*					_ogCoreDataStackTokenRef					= 0;
static NSPersistentStoreCoordinator*	_ogCoreDataStackPersistentStoreCoordinator	= nil;
static NSManagedObjectModel*			_ogCoreDataStackManagedObjectModel			= nil;

@implementation NSPersistentStoreCoordinator (OGCoreDataStack)

#pragma mark - Lifecycle

+ (instancetype)og_sharedPersistentStoreCoordinator
{
	BOOL success __attribute__((unused)) = [self og_setupWithStoreType:nil options:nil];
	
	NSAssert(success, @"Persistent Store setup failed");
	
	return _ogCoreDataStackPersistentStoreCoordinator;
}

+ (BOOL)og_setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options
{
    __block BOOL success         = YES;
    static dispatch_once_t token = 0;
    _ogCoreDataStackTokenRef     = &token;
	
	dispatch_once(&token, ^{
		
        NSString* coordinatorStoreType   = storeType;
        NSDictionary* coordinatorOptions = options;
		
		if (!coordinatorStoreType)
        {
            coordinatorStoreType = NSSQLiteStoreType;
        }
		
		if (!coordinatorOptions)
        {
            coordinatorOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        }
		
        NSError* error                             = nil;
        NSManagedObjectModel* model                = [[NSManagedObjectModel alloc] initWithContentsOfURL:_ogMomdURL()];
        _ogCoreDataStackPersistentStoreCoordinator = [[self alloc] initWithManagedObjectModel:model];
        success                                    = !![_ogCoreDataStackPersistentStoreCoordinator addPersistentStoreWithType:coordinatorStoreType configuration:nil URL:_ogPersistentStoreURL(storeType) options:coordinatorOptions error:&error];
		
		NSAssert(success, @"Add Persistent Store Error: %@\nMissing migration? %@", error.localizedDescription, ![error.userInfo[@"sourceModel"] isEqual:error.userInfo[@"destinationModel"]] ? @"YES" : @"NO");
	});
	
	return success;
}

+ (BOOL)og_reset
{
	if (!_ogCoreDataStackPersistentStoreCoordinator.persistentStores.count) return YES;
	
    NSError* error           = nil;
    NSPersistentStore* store = _ogCoreDataStackPersistentStoreCoordinator.persistentStores.firstObject;
    NSString* path           = _ogPersistentStoreURL(store.type).path;
    BOOL success             = [_ogCoreDataStackPersistentStoreCoordinator removePersistentStore:store error:&error];
	
	NSAssert(success, @"Remove Persistent Store Error: %@", error.localizedDescription);
	
	if (!success) return NO;
	
	NSArray* paths = @[path, [path stringByAppendingString:@"-wal"], [path stringByAppendingString:@"-shm"]];
	
	for (NSString* file in paths)
    {
		if ([NSFileManager.defaultManager fileExistsAtPath:file])
        {
            if (![NSFileManager.defaultManager removeItemAtPath:file error:&error])
            {
                NSAssert(success, @"Remove Persistent Store File Error: %@", error.localizedDescription);
                return NO;
            }
        }
	}
	
    *_ogCoreDataStackTokenRef                  = 0;
    _ogCoreDataStackPersistentStoreCoordinator = nil;
    _ogCoreDataStackManagedObjectModel         = nil;
	
	return YES;
}

@end
