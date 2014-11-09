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
 @param options The store options. Defaults to NSMigratePersistentStoresAutomaticallyOption and NSInferMappingModelAutomaticallyOption being YES for automatic light migrations.
 @return Whether the operation is successful.
 @note Call this before accessing any other part of the stack. E.g., in application:didFinishLaunchingWithOptions:.
 */
+ (BOOL)og_setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options;

/**
 Delete the persistent store.
 @return Whether the operation was successful.
 @note Remove all references to NSManagedObjects and NSManagedObjectContexts before calling this method.
 */
+ (BOOL)og_reset;

@end
