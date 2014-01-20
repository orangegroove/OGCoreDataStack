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
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

@implementation NSManagedObject (OGCoreDataStack)

#pragma mark - Lifecycke

+ (NSString *)entityName
{
	return NSStringFromClass(self.class);
}

+ (NSString *)uniqueIdAttributeName
{
	return nil;
}

#pragma mark - Populating

- (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary
{
	return dictionary;
}

- (void)populateWithDictionary:(NSDictionary *)dictionary options:(OGCoreDataStackPopulationOptions)options
{
	if (options & OGCoreDataStackPopulationOptionSkipTranslation) {
		
		if ([dictionary isKindOfClass:NSMutableDictionary.class])
			dictionary = [self translatedPopulationDictionary:(NSMutableDictionary *)dictionary];
		else
			dictionary = [self translatedPopulationDictionary:[NSMutableDictionary dictionaryWithDictionary:dictionary]];
	}
	
	if (options & OGCoreDataStackPopulationOptionBatchNotifications)
		[self _ogBatchNotificationsPopulateWithDictionary:dictionary options:options];
	else
		[self _ogPopulateWithDictionary:dictionary options:options];
}

#pragma mark - Private

- (void)_ogBatchNotificationsPopulateWithDictionary:(NSDictionary *)dictionary options:(OGCoreDataStackPopulationOptions)options
{
	BOOL typeCheck						= options & OGCoreDataStackPopulationOptionTypeCheck;
	NSDictionary* attributes			= self.entity.attributesByName;
	NSMutableArray* attributeKeys		= [NSMutableArray arrayWithArray:attributes.allKeys];
	NSMutableSet* accessedAttributes	= [NSMutableSet set];
	
	if (typeCheck)
		[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			
			if ([attributeKeys containsObject:key]) {
				
				NSAttributeDescription* attribute = attributes[key];
				
				if ([obj isKindOfClass:_ogClassForAttributeType(attribute.attributeType)]) {
					
					[self willChangeValueForKey:key];
					[accessedAttributes addObject:key];
				}
				
				[attributeKeys removeObject:key];
			}
		}];
	else
		for (id key in dictionary)
			if ([attributeKeys containsObject:key]) {
				
				[self willChangeValueForKey:key];
				[accessedAttributes addObject:key];
				[attributeKeys removeObject:key];
			}
	
	for (id key in accessedAttributes)
		[self setPrimitiveValue:dictionary[key] forKey:key];
	
	for (id key in accessedAttributes)
		[self didChangeValueForKey:key];
}

- (void)_ogPopulateWithDictionary:(NSDictionary *)dictionary options:(OGCoreDataStackPopulationOptions)options
{
	BOOL typeCheck					= options & OGCoreDataStackPopulationOptionTypeCheck;
	NSDictionary* attributes		= self.entity.attributesByName;
	NSMutableArray* attributeKeys	= [NSMutableArray arrayWithArray:attributes.allKeys];
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if ([attributeKeys containsObject:key]) {
			
			if (!typeCheck || [obj isKindOfClass:_ogClassForAttributeType(((NSAttributeDescription *)attributes[key]).attributeType)])
				[self setValue:obj forKey:key];
			
			[attributeKeys removeObject:key];
		}
	}];
}

@end
