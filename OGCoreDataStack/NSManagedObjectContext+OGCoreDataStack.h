//
//  NSManagedObjectContext+OGCoreDataStack.h
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
#import "OGCoreDataStackCommon.h"

typedef NS_ENUM(NSUInteger, OGCoreDataStackContextConcurrency)
{
	OGCoreDataStackContextConcurrencyMainQueue,
	OGCoreDataStackContextConcurrencyBackgroundQueue
};

@interface NSManagedObjectContext (OGCoreDataStack)

/** @name Lifecycle */

/**

*/
+ (instancetype)contextWithConcurrency:(OGCoreDataStackContextConcurrency)concurrency;

/**
 Saves the context. Shorthand for save:, but handles the error by printing to the console if DEBUG is defined.
 @return Operation success.
 */
- (BOOL)save;

/** @name Observing */

/**
 
 */
- (void)observeSavesInContext:(NSManagedObjectContext *)context;

/**
 
 */
- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context;

/** @name Operations */

/**
 Performs operations in a context and passes objects from from context to another.
 @param block The block of operations.
 @param objects The objects to pass.
 @note May fail if the objects do not have permanent NSManagedObjectIDs.
 */
- (void)performBlock:(void (^)(NSArray* objects))block passObjects:(NSArray *)objects;

/**
 Performs operations in a context, waits for the result and passes objects from from context to another.
 @param block The block of operations.
 @param objects The objects to pass.
 @note May fail if the objects do not have permanent NSManagedObjectIDs.
 */
- (void)performBlockAndWait:(void (^)(NSArray* objects))block passObjects:(NSArray *)objects;

/** @name Entities */

/**
 
 */
- (id)insertInEntity:(Class)entity;

/**
 
 */
- (NSArray *)fetchFromEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block;

/**
 
 */
- (NSUInteger)countEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block;

/**
 
 */
- (void)deleteFromEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block;

/**
 
 */
- (void)deleteObjects:(NSArray *)objects;

/**
 Obtains permanent NSManagedObjectIDs for objects. Shorthand for obtainPermanentIDsForObjects:error:, but handles the error by printing to the console if DEBUG is defined.
 @param objects The NSManagedObjects to save.
 @return Operation success.
 */
- (BOOL)obtainPermanentIDsForObjects:(NSArray *)objects;

@end
