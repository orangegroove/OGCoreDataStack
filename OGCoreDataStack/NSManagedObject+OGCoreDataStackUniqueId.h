//
//  NSManagedObject+OGCoreDataStackUniqueId.h
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

@interface NSManagedObject (OGCoreDataStackUniqueId)

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 The attribute name that represents the unique id attribute for this entity.
 @return The unique id key. Defaults to nil (no id attribute).
 @note This is intended to be used for synchronizing data with relational databases (such as data from web services). To easily import such data use the NSManagedObjectContext method createObjectsForEntity:withPopulationDictionaries:options:.
 */
+ (NSString *)og_uniqueIdAttributeName;

#pragma mark - Inserting

/**
 Inserts a new object into a context.
 @param uniqueId The unique id of the object to return.
 @param allowNil If false, the object is inserted into the context if it doesn't exist
 @param context The context.
 @return The newly created object.
 */
+ (instancetype)og_objectWithUniqueId:(id)uniqueId allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context;

/**
 Inserts new object into a context.
 @param uniqueIds An array of unique id's of the objects to return.
 @param allowNil If false, the objects are inserted into the context if they don't exist
 @param context The context.
 @return The newly created objects.
 @note The returned objects will have an undefined order.
 */
+ (NSArray *)og_objectsWithUniqueIds:(NSArray *)uniqueIds allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context;

@end
