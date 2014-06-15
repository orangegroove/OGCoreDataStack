//
//  OGCoreDataStackPopulationMapper.m
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

#import "OGCoreDataStackPopulationMapper.h"
#import "NSManagedObject+OGCoreDataStack.h"
#import "NSManagedObject+OGCoreDataStackUniqueId.h"
#import "OGCoreDataStackPrivate.h"

@implementation OGCoreDataStackPopulationMapper

#pragma mark - Lifecycle

- (instancetype)init
{
	if ((self = [super init])) {
		
		_translateUnderscoreToCamelCase = YES;
	}
	
	return self;
}

#pragma mark - Population

- (void)populateObject:(NSManagedObject *)object withDictionary:(NSDictionary *)dictionary
{
	NSParameterAssert(object);
	NSParameterAssert(dictionary);
	
	for (NSString* key in dictionary) {
		
		NSParameterAssert([key isKindOfClass:NSString.class]);
		
		NSString* attributeName = [self attributeNameForPopulationKey:key object:object];
		
		if (!attributeName)
			continue;
		
		id value				= dictionary[key];
		SEL populateSelector	= NSSelectorFromString([NSString stringWithFormat:@"populateObject:%@WithValue:", attributeName]);
		
		if ([value isKindOfClass:NSNull.class])
			value = nil;
		
		if ([self respondsToSelector:populateSelector])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self performSelector:populateSelector withObject:value];
#pragma clang diagnostic pop
		else
			[object setValue:value forKey:attributeName];
	}
}

- (void)populateObjects:(NSArray *)objects withDictionaries:(NSArray *)dictionaries
{
	NSParameterAssert(objects.count && objects.count == dictionaries.count);
	
	for (NSUInteger i = 0; i < objects.count; i++)
		[self populateObject:objects[i] withDictionary:dictionaries[i]];
}

#pragma mark - Creation

- (id)createObjectOfClass:(Class)class withDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context
{
	NSParameterAssert(class);
	
	if (!dictionary)
		return nil;
	
	return [self createObjectsOfClass:class withDictionaries:@[dictionary] context:context].firstObject;
}

- (NSArray *)createObjectsOfClass:(Class)class withDictionaries:(NSArray *)dictionaries context:(NSManagedObjectContext *)context
{
	NSParameterAssert(class);
	
	if (!dictionaries)
		return nil;
	
	if (!dictionaries.count)
		return @[];
	
	NSString* uniqueIdAttributeName = [class og_uniqueIdAttributeName];
	
	if (uniqueIdAttributeName) {
		
		NSArray* uniqueIds	= [dictionaries valueForKey:uniqueIdAttributeName];
		NSArray* objects	= [class og_objectsWithUniqueIds:[NSSet setWithArray:uniqueIds] allowNil:NO context:context];
		
		for (id object in objects) {
			
			id uniqueId			= [object valueForKey:uniqueIdAttributeName];
			NSUInteger index	= [dictionaries indexOfObjectPassingTest:^BOOL(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
				
				return [uniqueId isEqual:obj[uniqueIdAttributeName]];
			}];
			
			NSAssert(index != NSNotFound, @"");
			
			[self populateObject:object withDictionary:dictionaries[index]];
		}
		
		return objects;
	}
	else {
		
		NSMutableArray* objects = [NSMutableArray array];
		
		for (NSDictionary* dictionary in dictionaries) {
			
			id object = [class og_createObjectInContext:context];
			
			[self populateObject:object withDictionary:dictionary];
			[objects addObject:object];
		}
		
		return [NSArray arrayWithArray:objects];
	}
}

#pragma mark - Configuration

- (NSString *)attributeNameForPopulationKey:(NSString *)key object:(NSManagedObject *)object
{
	if ([object.entity.attributesByName.allKeys containsObject:key])
		return _ogCamelCaseFromUnderscore(key);
	
	return nil;
}

@end
