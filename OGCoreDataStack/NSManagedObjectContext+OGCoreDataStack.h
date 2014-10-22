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

@interface NSManagedObjectContext (OGCoreDataStack)

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 Saves the context. Shorthand for save:, but asserts that the operation was successful.
 @return Operation success.
 */
- (BOOL)og_save;

#pragma mark - Observing
/** @name Observing */

/**
 Starts observing for saves made in the specified context. Automatically merges those changes.
 @param context The context to observe.
 */
- (void)og_observeSavesInContext:(NSManagedObjectContext *)context;

/**
 Stops observing a context for saves.
 @param context The context to stop observing.
 */
- (void)og_stopObservingSavesInContext:(NSManagedObjectContext *)context;

/**
 Checks whether a context is observed for saves.
 @param context The context to check.
 @return
 */
- (BOOL)og_isObservingSavesInContext:(NSManagedObjectContext *)context;

#pragma mark - Operations
/** @name Operations */

/**
 Performs operations in a context and passes objects from from context to another.
 @param block The block of operations.
 @param objects The objects to pass.
 @note May fail if the objects do not have permanent NSManagedObjectIDs.
 */
- (void)og_performBlock:(void (^)(NSArray* objects))block passObjects:(NSArray *)objects;

/**
 Performs operations in a context, waits for the result and passes objects from from context to another.
 @param block The block of operations.
 @param objects The objects to pass.
 @note May fail if the objects do not have permanent NSManagedObjectIDs.
 */
- (void)og_performBlockAndWait:(void (^)(NSArray* objects))block passObjects:(NSArray *)objects;

@end
