//
//  NSManagedObject+OGCoreDataStackPopulation.m
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

#import "NSManagedObject+OGCoreDataStackPopulation.h"
#import "NSManagedObject+OGCoreDataStack.h"
#import "NSManagedObject+OGCoreDataStackUniqueId.h"
#import "OGCoreDataStackMappingConfiguration.h"

static NSMutableDictionary*	_ogOGCoreDataStackMappingConfigurationCache = nil;

@implementation NSManagedObject (OGCoreDataStackPopulation)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		_ogOGCoreDataStackMappingConfigurationCache = [NSMutableDictionary dictionary];
	});
}

+ (OGCoreDataStackMappingConfiguration *)_ogMappingConfiguration
{
	Class class									= self.og_mappingConfigurationClass;
	NSString* key								= NSStringFromClass(class);
	OGCoreDataStackMappingConfiguration* config	= _ogOGCoreDataStackMappingConfigurationCache[key];
	
	if (!config)
		@synchronized(config)
		{
			config												= [[class alloc] init];
			_ogOGCoreDataStackMappingConfigurationCache[key]	= config;
		}
	
	return config;
}

#pragma mark - Configuration

+ (Class)og_mappingConfigurationClass
{
	return OGCoreDataStackMappingConfiguration.class;
}

#pragma mark - Creating

+ (id)og_createObjectInContext:(NSManagedObjectContext *)context populateWithDictionary:(NSDictionary *)dictionary
{
	if (!dictionary)
		return nil;
	
	return [self og_createObjectsInContext:context populateWithDictionaries:@[dictionary]].firstObject;
}

+ (NSArray *)og_createObjectsInContext:(NSManagedObjectContext *)context populateWithDictionaries:(NSArray *)dictionaries
{
	if (!dictionaries)
		return nil;
	
	if (!dictionaries.count)
		return @[];
	
	NSString* uniqueIdAttributeName = [self og_uniqueIdAttributeName];
	
	if (uniqueIdAttributeName) {
		
		NSArray* uniqueIds	= [dictionaries valueForKey:uniqueIdAttributeName];
		NSArray* objects	= [self og_objectsWithUniqueIds:[NSSet setWithArray:uniqueIds] allowNil:NO context:context];
		
		for (id object in objects) {
			
			id uniqueId			= [object valueForKey:uniqueIdAttributeName];
			NSUInteger index	= [dictionaries indexOfObjectPassingTest:^BOOL(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
				
				return [uniqueId isEqual:obj[uniqueIdAttributeName]];
			}];
			
			NSAssert(index != NSNotFound, @"");
			[object og_populateWithDictionary:dictionaries[index]];
		}
		
		return objects;
	}
	else {
		
		NSMutableArray* objects = [NSMutableArray array];
		
		for (NSDictionary* dictionary in dictionaries) {
			
			id object = [self og_createObjectInContext:context];
			
			[object og_populateWithDictionary:dictionary];
			[objects addObject:object];
		}
		
		return [NSArray arrayWithArray:objects];
	}
}

#pragma mark - Populating

- (void)og_populateWithDictionary:(NSDictionary *)dictionary
{
	NSParameterAssert(dictionary);
	
	OGCoreDataStackMappingConfiguration* config = self.class._ogMappingConfiguration;
	
	for (NSString* key in dictionary) {
		
		NSParameterAssert([key isKindOfClass:NSString.class]);
		
		BOOL relationship		= NO;
		NSString* attributeName = [config attributeNameForPopulationKey:key object:self];
		
		if (!attributeName) {
			
			relationship	= YES;
			attributeName	= [config relationshipNameForPopulationKey:key object:self];
			
			if (!attributeName)
				continue;
		}
		
		id value				= dictionary[key];
		SEL populateSelector	= NSSelectorFromString([NSString stringWithFormat:@"populateObject:%@WithValue:", attributeName]);
		
		if ([value isKindOfClass:NSNull.class])
			value = nil;
		
		if ([self respondsToSelector:populateSelector])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[config performSelector:populateSelector withObject:self withObject:value];
#pragma clang diagnostic pop
		else if (!relationship)
			[self setValue:value forKey:attributeName];
	}
}

@end
