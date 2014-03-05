//
//  OGManagedObject.h
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

@interface OGManagedObject : NSManagedObject

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 The entity name for this class. Override this if your entity is not named the same as your class.
 @return The entity name in the NSManagedObjectModel.
 @note mogenerator generates this method automatically.
 */
+ (NSString *)entityName;

/**
 The attribute name that represents the unique id attribute for this entity.
 @return The unique id key. Defaults to nil (no id attribute).
 @note This is intended to be used for synchronizing data with relational databases (such as data from web services). To easily import such data use the NSManagedObjectContext method createObjectsForEntity:withPopulationDictionaries:options:.
 */
+ (NSString *)uniqueIdAttributeName;

/**
 
 @return
 */
+ (NSFetchRequest *)fetchRequest;

#pragma mark - Inserting

/**
 Inserts a new object into this context.
 @param entity The class of the entity to insert.
 @return The newly created object.
 */
+ (id)createObjectInContext:(NSManagedObjectContext *)context;

#pragma mark - Fetching

/**
 Fetches objects from the context.
 @param entity The class of the entity to fetch.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate, or a sort descriptor).
 @return The fetched objects.
 */
+ (NSArray *)fetchWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

#pragma mark - Counting

/**
 Counts objects in the context.
 @param entity The class of the entity to count.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate).
 @return The number of objects.
 @note Any sort descriptors added to the NSFetchRequest are automatically removed before execution.
 */
+ (NSUInteger)countWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

#pragma mark - Deleting

/**
 Deletes objects from the context.
 @param entity The class of the entity to delete.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate).
 @warning If you do not add a predicate to the NSFetchRequest, all objects in the entity will be deleted.
 */
+ (void)deleteWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

/**
 Delete objects from the context.
 @param objects An array with objects to delete.
 */
- (void)delete;

#pragma mark - Miscellaneous

/**
 Obtains permanent NSManagedObjectIDs for objects. Shorthand for obtainPermanentIDsForObjects:error:, but asserts that the operation was successful.
 @param objects The NSManagedObjects to convert.
 @return Operation success.
 */
- (BOOL)obtainPermanentID;

@end
