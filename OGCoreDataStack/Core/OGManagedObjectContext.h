//
//  OGManagedObjectContext.h
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

@interface OGManagedObjectContext : NSManagedObjectContext

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 Returns a new context.
 @param concurrency Specifies the serial queue to which the context belongs. See OGCoreDataStackCommon.h for details.
 @return The new context.
 @note The context will be tied directly to the persistent store and does not use the child/parent pattern.
 */
+ (instancetype)newContextWithConcurrency:(OGCoreDataStackContextConcurrency)concurrency;

/**
 Returns the concurrency type of the context.
 */
- (OGCoreDataStackContextConcurrency)contextConcurrency;

/**
 Saves the context. Shorthand for save:, but asserts that the operation was successful.
 @return Operation success.
 */
- (BOOL)save;

#pragma mark - Observing
/** @name Observing */

/**
 Starts observing for saves made in the specified context. Automatically merges those changes.
 @param context The context to observe.
 */
- (void)observeSavesInContext:(NSManagedObjectContext *)context;

/**
 Stops observing a context for saves.
 @param context The context to stop observing.
 */
- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context;

/**
 Checks whether a context is observed for saves.
 @param context The context to check.
 @return
 */
- (BOOL)isObservingSavesInContext:(NSManagedObjectContext *)context;

#pragma mark - Operations
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

@end
