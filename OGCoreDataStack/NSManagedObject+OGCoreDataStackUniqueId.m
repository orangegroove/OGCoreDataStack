//
//  NSManagedObject+OGCoreDataStackUniqueId.m
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

#import "NSManagedObject+OGCoreDataStackUniqueId.h"
#import "NSManagedObject+OGCoreDataStack.h"

@implementation NSManagedObject (OGCoreDataStackUniqueId)

#pragma mark - Lifecycle

+ (NSString *)uniqueIdAttributeName
{
	return nil;
}

#pragma mark - Inserting

+ (instancetype)objectWithUniqueId:(id)uniqueId allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context
{
	return [self objectsWithUniqueIds:@[uniqueId] allowNil:allowNil context:context].firstObject;
}

+ (NSArray *)objectsWithUniqueIds:(NSArray *)uniqueIds allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context
{
	NSString* uniqueIdAttributeName = self.uniqueIdAttributeName;
	
	NSParameterAssert(uniqueIds.count);
	NSParameterAssert(uniqueIdAttributeName);
	NSParameterAssert(context);
	
	NSMutableArray* objects = [NSMutableArray arrayWithArray:[self fetchWithRequest:^(NSFetchRequest *request) {
		
		request.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", uniqueIdAttributeName, uniqueIds];
		
	} context:context]];
	
	if (!allowNil && objects.count != uniqueIds.count) {
		
		NSMutableArray* missingIds = [NSMutableArray arrayWithArray:uniqueIds];
		[missingIds removeObjectsInArray:[objects valueForKey:uniqueIdAttributeName]];
		
		for (id uniqueId in missingIds) {
			
			id object = [self createObjectInContext:context];
			
			[object setValue:uniqueId forKeyPath:uniqueIdAttributeName];
			[objects addObject:object];
		}
	}
	
	return [NSArray arrayWithArray:objects];
}

@end
