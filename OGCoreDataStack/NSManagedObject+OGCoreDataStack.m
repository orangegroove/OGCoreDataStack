//
//  NSManagedObject+OGCoreDataStack.m
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

#import "NSManagedObject+OGCoreDataStack.h"

@implementation NSManagedObject (OGCoreDataStack)

#pragma mark - Lifecycle

+ (NSString *)og_entityName
{
	return NSStringFromClass(self.class);
}

+ (NSFetchRequest *)og_fetchRequest
{
	return [NSFetchRequest fetchRequestWithEntityName:self.og_entityName];
}

#pragma mark - Inserting

+ (instancetype)og_createObjectInContext:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	return [NSEntityDescription insertNewObjectForEntityForName:self.og_entityName inManagedObjectContext:context];
}

#pragma mark - Fetching

+ (NSArray *)og_fetchWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:self.og_entityName];
	NSError* error			= nil;
	
	if (block)
		block(request);
	
	NSArray* objects = [context executeFetchRequest:request error:&error];
	
	NSAssert(!error, @"Fetch Error: %@", error.localizedDescription);
	
	return objects;
}

#pragma mark - Counting

+ (NSUInteger)og_countWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	NSFetchRequest* request	= [NSFetchRequest fetchRequestWithEntityName:self.og_entityName];
	NSError* error			= nil;
	
	if (block)
		block(request);
	
	request.sortDescriptors	= nil;
	NSUInteger count		= [context countForFetchRequest:request error:&error];
	
	NSAssert(count != NSNotFound, @"Count Error: %@", error.localizedDescription);
	
	return count;
}

#pragma mark - Deleting

+ (NSUInteger)og_deleteWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSParameterAssert(context);
	
	NSArray* objects = [self og_fetchWithRequest:^(NSFetchRequest *request) {
		
		if (block)
			block(request);
		
		request.returnsObjectsAsFaults				= YES;
		request.includesPropertyValues				= NO;
		request.sortDescriptors						= nil;
		request.relationshipKeyPathsForPrefetching	= nil;
		
	} context:context];
	
	NSUInteger count = objects.count;
	
	for (NSManagedObject* object in objects)
		[object og_delete];
	
	return count;
}

- (void)og_delete
{
	[self.managedObjectContext deleteObject:self];
}

#pragma mark - Miscellaneous

- (BOOL)og_obtainPermanentID
{
	NSError* error	= nil;
	BOOL success	= [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:&error];
	
	NSAssert(success, @"ObtainPermanentID Error: %@", error.localizedDescription);
	
	return success;
}

@end
