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

NSString * const OGCoreDataStackStoreOptionDirectoryURL = @"OGCoreDataStackStoreOptionDirectoryURL";
NSString * const OGCoreDataStackStoreOptionICloudBackup = @"OGCoreDataStackStoreOptionICloudBackup";

static dispatch_once_t* _ogCoreDataStackTokenRef                                = 0;
static NSPersistentStoreCoordinator* _ogCoreDataStackPersistentStoreCoordinator = nil;
static NSManagedObjectModel* _ogCoreDataStackManagedObjectModel                 = nil;

@implementation NSPersistentStoreCoordinator (OGCoreDataStack)

#pragma mark - Lifecycle

+ (instancetype)og_sharedPersistentStoreCoordinator
{
	BOOL success __attribute__((unused)) = [self og_setupWithStoreType:nil options:nil error:nil];
	
	NSAssert(success, @"Persistent Store setup failed");
	
	return _ogCoreDataStackPersistentStoreCoordinator;
}

+ (BOOL)og_setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options error:(NSError *__autoreleasing *)error
{
    __block BOOL success         = YES;
    static dispatch_once_t token = 0;
    _ogCoreDataStackTokenRef     = &token;
	
	dispatch_once(&token, ^{
		
        NSManagedObjectModel* model         = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self og_MomdURL]];
        NSMutableDictionary* mutableOptions = [NSMutableDictionary dictionaryWithDictionary:options];
        NSString* coordinatorStoreType      = storeType;
		
		if (!coordinatorStoreType)
        {
            coordinatorStoreType = NSSQLiteStoreType;
        }
        
        NSURL* storeURL               = options[OGCoreDataStackStoreOptionDirectoryURL];
        NSNumber* cloudBackup         = options[OGCoreDataStackStoreOptionICloudBackup];
        if (!storeURL)    storeURL    = [self og_persistentStoreURLForType:storeType];
        if (!cloudBackup) cloudBackup = @NO;
        
        [self og_validateOptions:mutableOptions];
        
        NSError* storeError                        = nil;
        _ogCoreDataStackPersistentStoreCoordinator = [[self alloc] initWithManagedObjectModel:model];
        success                                    = !![_ogCoreDataStackPersistentStoreCoordinator addPersistentStoreWithType:coordinatorStoreType configuration:nil URL:storeURL options:mutableOptions error:&storeError];
        
        if (success && storeURL && [NSFileManager.defaultManager fileExistsAtPath:storeURL.path])
        {
            success = [storeURL setResourceValue:@(!cloudBackup.boolValue) forKey:NSURLIsExcludedFromBackupKey error:&storeError];
        }
        
		NSAssert(success, @"Add Persistent Store Error: %@\nMissing migration? %@", storeError.localizedDescription, ![storeError.userInfo[@"sourceModel"] isEqual:storeError.userInfo[@"destinationModel"]] ? @"YES" : @"NO");
        
        if (error)
        {
            *error = storeError;
        }
	});
	
	return success;
}

+ (BOOL)og_reset
{
	if (!_ogCoreDataStackPersistentStoreCoordinator.persistentStores.count) return YES;
	
    NSError* error           = nil;
    NSPersistentStore* store = _ogCoreDataStackPersistentStoreCoordinator.persistentStores.firstObject;
    NSString* path           = [self og_persistentStoreURLForType:store.type].path;
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

#pragma mark - Private

+ (void)og_validateOptions:(NSMutableDictionary *)options
{
    [options removeObjectForKey:OGCoreDataStackStoreOptionDirectoryURL];
    [options removeObjectForKey:OGCoreDataStackStoreOptionICloudBackup];
    
    if (!options[NSMigratePersistentStoresAutomaticallyOption])
    {
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
    }
    
    if (!options[NSInferMappingModelAutomaticallyOption])
    {
        options[NSInferMappingModelAutomaticallyOption] = @YES;
    }
}

+ (NSURL *)og_MomdURL
{
    NSString* bundle = [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSArray* urls    = [[NSBundle bundleWithIdentifier:bundle] URLsForResourcesWithExtension:@"momd" subdirectory:nil];
    
    NSCAssert(urls.count == 1, @"Create Managed Object Model Error: Looking for 1 Momd in main bundle, found %lu", (unsigned long)urls.count);
    
    return urls.firstObject;
}

+ (NSURL *)og_persistentStoreURLForType:(NSString *)storeType
{
    if ([storeType isEqualToString:NSInMemoryStoreType]) return nil;
    
    NSString* filename	= [self og_MomdURL].lastPathComponent;
    NSString* modelname	= [filename substringWithRange:NSMakeRange(0, filename.length-5)];
    NSArray* urls		= [NSFileManager.defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    return [urls.lastObject URLByAppendingPathComponent:modelname];
}

@end
