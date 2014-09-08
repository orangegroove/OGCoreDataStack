//
//  NSManagedObject+OGCoreDataStack.h
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

#import "OGCoreDataStackCommon.h"

@interface NSManagedObject (OGCoreDataStack)

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 The entity name for this class. Override this if your entity is not named the same as your class.
 @return The entity name in the NSManagedObjectModel.
 @note mogenerator generates this method automatically.
 */
+ (NSString *)og_entityName;

#pragma mark - Inserting
/** @name Inserting */

/**
 Inserts a new object into this context.
 @param context The context in which to insert the object.
 @return The newly created object.
 */
+ (instancetype)og_createObjectInContext:(NSManagedObjectContext *)context;

#pragma mark - Fetching
/** @name Fetching */

/**
 Fetches objects from the context.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate, or a sort descriptor).
 @param context The context from which to fetch the objects.
 @return The fetched objects.
 */
+ (NSArray *)og_fetchWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

#pragma mark - Counting
/** @name Counting */

/**
 Counts objects in the context.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate).
 @param context The context in which to count the objects.
 @return The number of objects.
 @note Any sort descriptors added to the NSFetchRequest are automatically removed before execution.
 */
+ (NSUInteger)og_countWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

#pragma mark - Deleting
/** @name Deleting */

/**
 Deletes objects from the context.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate).
 @param context The context in which to delete the objects.
 @return The number of objects that were deleted.
 @warning If you do not add a predicate to the NSFetchRequest, all objects in the entity will be deleted.
 */
+ (NSUInteger)og_deleteWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

/**
 Delete objects from the context.
 @param objects An array with objects to delete.
 */
- (void)og_delete;

#pragma mark - Batching
/** @name Batching */

/**
 Performs a batch update.
 @param block Modify the NSBatchUpdateRequest to be used in this block (e.g., to add a predicate and an operation).
 @param context The context in which to update the objects.
 @param result Filled with a value depending on the NSBatchUpdateRequest resultType.
 @return The success of the operation.
 */
+ (BOOL)og_updateWithRequest:(OGCoreDataStackBatchUpdateRequestBlock)block context:(NSManagedObjectContext *)context result:(id *)result NS_AVAILABLE_IOS(8_0);

#pragma mark - Miscellaneous
/** @name Miscellaneous */

/**
 Obtains permanent NSManagedObjectIDs for objects. Shorthand for obtainPermanentIDsForObjects:error:, but asserts that the operation was successful.
 @param objects The NSManagedObjects to convert.
 @return Operation success.
 */
- (BOOL)og_obtainPermanentID;

@end
