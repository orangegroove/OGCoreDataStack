//
//  NSPersistentStoreCoordinator+OGCoreDataStack.h
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

@import CoreData;

#pragma mark - Store Options
/** @name Store Options */

/**
 The directory in which to store the sqlite file.
 Defaults to NSLibraryDirectory in the user domain.
 Not relevant for NSInMemoryStoreType.
 The value should be an NSURL.
 */
extern NSString * const OGCoreDataStackStoreOptionDirectoryURL;

/**
 Whether to back up the sqlite file to iCloud.
 Only applicable if the file is stored in certain directories.
 Defaults to NO.
 The value should be an NSNumber.
 */
extern NSString * const OGCoreDataStackStoreOptionICloudBackup;

/*
 Extensions to NSPersistentStoreCoordinator.
 */

@interface NSPersistentStoreCoordinator (OGCoreDataStack)

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 The singleton NSPersistentStoreCoordinator for use with the stack.
 @return The PSC.
 */
+ (instancetype)og_sharedPersistentStoreCoordinator;

/**
 Customize the persistent store coordinator.
 @param storeType The type of store to create. Defaults to NSSQLiteStoreType.
 @param options The store options. Defaults to NSMigratePersistentStoresAutomaticallyOption and NSInferMappingModelAutomaticallyOption being YES for automatic light migrations. For additional options @see Store Options.
 @param error Failure reason.
 @return Whether the operation is successful.
 @note Call this before accessing any other part of the stack. E.g., in application:didFinishLaunchingWithOptions:.
 */
+ (BOOL)og_setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options error:(NSError **)error;

/**
 Delete the persistent store.
 @return Whether the operation was successful.
 @note Remove all references to NSManagedObjects and NSManagedObjectContexts before calling this method.
 */
+ (BOOL)og_reset;

@end
