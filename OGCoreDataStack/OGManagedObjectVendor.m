//
//  OGManagedObjectVendor.m
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

#import "OGManagedObjectVendor.h"
#import "OGCoreDataStackCore.h"
#import "OGCoreDataStackPrivate.h"

@interface OGManagedObjectVendor ()

@property (strong, nonatomic) NSFetchRequest*				fetchRequest;
@property (strong, nonatomic) NSManagedObjectContext*		managedObjectContext;
@property (copy, nonatomic)   NSString*						sectionNameKeyPath;
@property (strong, nonatomic) NSString*						cacheName;
@property (strong, nonatomic) NSFetchedResultsController*	fetchedResultsController;
@property (strong, nonatomic) NSMutableIndexSet*			insertedSections;
@property (strong, nonatomic) NSMutableIndexSet*			deletedSections;
@property (strong, nonatomic) NSMutableArray*				insertedObjects;
@property (strong, nonatomic) NSMutableArray*				deletedObjects;
@property (strong, nonatomic) NSMutableArray*				updatedObjects;

- (BOOL)indexPathIsValid:(NSIndexPath *)indexPath;
- (void)callObjectsUpdatedBlock;

@end
@implementation OGManagedObjectVendor

#pragma mark - Public

- (void)setEntity:(Class)entity request:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName
{
	NSParameterAssert(entity);
	NSParameterAssert(context);
	
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[entity entityName]];
	
	if (block)
		block(request);
	
	self.fetchRequest			= request;
	self.managedObjectContext	= context;
	self.sectionNameKeyPath		= sectionNameKeyPath;
	self.cacheName				= cacheName;
}

- (NSInteger)numberOfSections
{
	return (NSInteger)self.fetchedResultsController.sections.count;
}

- (NSInteger)numberOfObjectsInSection:(NSInteger)section
{
	NSArray* sections = self.fetchedResultsController.sections;
	
	if (section > ((NSInteger)sections.count)-1)
		return 0;
	
	id<NSFetchedResultsSectionInfo> sectionInfo = sections[(NSUInteger)section];
	
	return (NSInteger)sectionInfo.numberOfObjects;
}

- (NSInteger)numberOfObjects
{
	NSInteger count = 0;
	
	for (id<NSFetchedResultsSectionInfo> sectionInfo in self.fetchedResultsController.sections)
		count += (NSInteger)sectionInfo.numberOfObjects;
	
	return count;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	if (![self indexPathIsValid:indexPath])
		return nil;
	
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object
{
	return [self.fetchedResultsController indexPathForObject:object];
}

- (id)objectForKeyedSubscript:(id)key
{
	if (![key isKindOfClass:NSIndexPath.class] || ![self indexPathIsValid:key])
		return nil;
	
	return [self.fetchedResultsController objectAtIndexPath:key];
}

- (id)firstObjectInSection:(NSInteger)section
{
	NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
	
	return [self objectAtIndexPath:indexPath];
}

- (id)lastObjectInSection:(NSInteger)section
{
	NSInteger item			= [self numberOfObjectsInSection:section]-1;
	NSIndexPath* indexPath	= [NSIndexPath indexPathForItem:item inSection:section];
	
	return [self objectAtIndexPath:indexPath];
}

- (NSArray *)objectsInSection:(NSInteger)section
{
	return [self section:section].objects;
}

- (NSArray *)allObjects
{
	return self.fetchedResultsController.fetchedObjects;
}

- (id<NSFetchedResultsSectionInfo>)section:(NSInteger)section
{
	NSArray* sections = self.fetchedResultsController.sections;
	
	if (section > ((NSInteger)sections.count)-1)
		return nil;
	
	return sections[(NSUInteger)section];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (!self.isPaused)
		return;
	
	if (self.objectsUpdated)
		[self callObjectsUpdatedBlock];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch (type) {
			
		case NSFetchedResultsChangeInsert:
			
			[self.insertedSections addIndex:sectionIndex];
			
			break;
			
		case NSFetchedResultsChangeDelete:
			
			[self.deletedSections addIndex:sectionIndex];
			
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type) {
		case NSFetchedResultsChangeInsert:
			
			if (![self.insertedSections containsIndex:newIndexPath.section])
				[self.insertedObjects addObject:newIndexPath];
			
			break;
			
		case NSFetchedResultsChangeDelete:
			
			if (![self.deletedSections containsIndex:indexPath.section])
				[self.deletedObjects addObject:indexPath];
			
			break;
			
		case NSFetchedResultsChangeMove:
			
			if (![self.insertedSections containsIndex:newIndexPath.section])
				[self.insertedObjects addObject:newIndexPath];
			
			if (![self.deletedSections containsIndex:indexPath.section])
				[self.deletedObjects addObject:indexPath];
			
			break;
			
		case NSFetchedResultsChangeUpdate:
			
			[self.updatedObjects addObject:indexPath];
			
			break;
	}
}

#pragma mark - Private

- (BOOL)indexPathIsValid:(NSIndexPath *)indexPath
{
	if (indexPath.section >= self.fetchedResultsController.sections.count)
		return NO;
	
	id<NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[(NSUInteger)indexPath.section];
	
	if (indexPath.item >= info.numberOfObjects)
		return NO;
	
	return YES;
}

- (void)callObjectsUpdatedBlock
{
	self.objectsUpdated(self.insertedSections, self.deletedSections, self.insertedObjects, self.deletedObjects, self.updatedObjects);
	
	self.deletedSections	= nil;
	self.insertedSections	= nil;
	self.deletedObjects		= nil;
	self.insertedObjects	= nil;
	self.updatedObjects		= nil;
}

#pragma mark - Properties

- (void)setVending:(BOOL)vending
{
	if (!self.fetchRequest || !self.managedObjectContext)
		return;
	
	if (vending && !_vending) {
		
		self.fetchedResultsController			= [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:self.cacheName];
		self.fetchedResultsController.delegate	= self;
		NSError* error							= nil;
		_vending								= [self.fetchedResultsController performFetch:&error];
		
		NSAssert(vending, @"Enable vending error: %@", error);
		
		if (!_vending)
			self.vending = NO;
	}
	else if (!vending) {
		
		self.fetchedResultsController.delegate	= nil;
		self.fetchedResultsController			= nil;
		_vending								= NO;
	}
}

- (void)setPaused:(BOOL)paused
{
	if (!paused && _paused && self.isVending && self.objectsUpdated)
		[self callObjectsUpdatedBlock];
	
	_paused = paused;
}

- (NSMutableIndexSet *)deletedSections
{
	if (_deletedSections)
		return _deletedSections;
	
	_deletedSections = [NSMutableIndexSet indexSet];
	
	return _deletedSections;
}

- (NSMutableIndexSet *)insertedSections
{
	if (_insertedSections)
		return _insertedSections;
	
	_insertedSections = [NSMutableIndexSet indexSet];
	
	return _insertedSections;
}

- (NSMutableArray *)insertedObjects
{
	if (_insertedObjects)
		return _insertedObjects;
	
	_insertedObjects = [NSMutableArray array];
	
	return _insertedObjects;
}

- (NSMutableArray *)deletedObjects
{
	if (_deletedObjects)
		return _deletedObjects;
	
	_deletedObjects = [NSMutableArray array];
	
	return _deletedObjects;
}

- (NSMutableArray *)updatedObjects
{
	if (_updatedObjects)
		return _updatedObjects;
	
	_updatedObjects = [NSMutableArray array];
	
	return _updatedObjects;
}

@end
