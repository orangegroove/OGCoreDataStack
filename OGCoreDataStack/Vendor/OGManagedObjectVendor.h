//
//  OGManagedObjectVendor.h
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

#import "../Core/OGCoreDataStackCommon.h"

/**
 NSFetchedResultsController decorator.
 */

typedef void (^OGCoreDataStackVendorObjectsUpdated)(NSIndexSet* insertedSections, NSIndexSet* deletedSections, NSArray* insertedItems, NSArray* deletedItems, NSArray* updatedItems);

@interface OGManagedObjectVendor : NSObject
<NSFetchedResultsControllerDelegate>

/**
 Toggles whether the vendor is enabled and serving objects.
 */
@property (assign, nonatomic, getter=isVending) BOOL vending;

/**
 Pauses vending. Stops calling of the objectsUpdated block, but it's still possible to get objects manually.
 */
@property (assign, nonatomic, getter=isPaused) BOOL paused;

/**
 The fetch request used for filtering and sorting objects. Any changes made to this object will not be reflected until the vending is toggled off, then on.
 */
@property (strong, nonatomic, readonly) NSFetchRequest* fetchRequest;

/**
 The context to which vended objects belong.
 */
@property (strong, nonatomic, readonly) NSManagedObjectContext* managedObjectContext;

/**
 The keypath on the objects used to divide them into sections.
 */
@property (copy, nonatomic, readonly) NSString* sectionNameKeyPath;

/**
 The name of the file in which to store the cached fetch.
 */
@property (strong, nonatomic, readonly) NSString* cacheName;

/**
 This block is called after every batch of updates to the objects.
 */
@property (copy, nonatomic) OGCoreDataStackVendorObjectsUpdated	objectsUpdated;

#pragma mark - Lifecycle
/** @name Lifecycle */

/**
 Initializes the vendor.
 @param entity The class of the entity to vend.
 @param block Modify the NSFetchRequest to be used in this block (e.g., to add a predicate, or a sort descriptor). You must add at least one sort descriptor.
 @param context The context in which to vend objects.
 @param sectionNameKeyPath The keypath on the objects used to divide them into sections. Can be nil.
 @param cacheName The name of the file in which to store the cached fetch. Can be nil.
 */
- (void)setEntity:(Class)entity request:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName;

#pragma mark - Counting
/** @name Counting */

/**
 The section count.
 @return The count.
 */
- (NSInteger)numberOfSections;

/**
 The object count for a section.
 @param section The section to count.
 @return The count.
 */
- (NSInteger)numberOfObjectsInSection:(NSInteger)section;

/**
 The object count over all sections.
 @return The count.
 */
- (NSInteger)numberOfObjects;

#pragma mark - Objects
/** @name Objects */

/**
 Retrieves a specific object.
 @param indexPath The indexpath of the object.
 @return The object or nil.
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 Retrieves an indexpath of a specific object.
 @param object The object.
 @return The indexpath or nil.
 */
- (NSIndexPath *)indexPathForObject:(id)object;

/**
 Keyed subscript support for getting objects, like so: vendor[[NSIndexPath indexPathForItem:0 section:0]].
 @param key The indexpath of the object.
 @return The object or nil.
 */
- (id)objectForKeyedSubscript:(id)key;

/**
 Retrieves the first object of a section.
 @param section The index of the section.
 @return The object or nil.
 */
- (id)firstObjectInSection:(NSInteger)section;

/**
 Retrieves the last object of a section.
 @param section The index of the section.
 @return The object or nil.
 */
- (id)lastObjectInSection:(NSInteger)section;

/**
 Retrieves all objects in a section.
 @param section The index of the section.
 @return An array with zero or more objects, or nil.
 */
- (NSArray *)objectsInSection:(NSInteger)section;

/**
 Retrieves all objects.
 @return An array with zero or more objects, or nil.
 */
- (NSArray *)allObjects;

#pragma mark - Sections
/** @name Sections */

/**
 Returns the section information object.
 @param section The index of the section.
 @return The section info object.
 */
- (id<NSFetchedResultsSectionInfo>)section:(NSInteger)section;

@end
