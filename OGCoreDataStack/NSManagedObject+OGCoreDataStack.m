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

#pragma mark - Populating

+ (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary
{
	return dictionary;
}

- (void)populateWithDictionary:(NSMutableDictionary *)dictionary typeCheck:(BOOL)typeCheck
{
	NSDictionary* attributes			= self.entity.attributesByName;
	NSMutableArray* attributeKeys		= [NSMutableArray arrayWithArray:attributes.allKeys];
	dictionary							= [self.class translatedPopulationDictionary:dictionary];
#ifdef DEBUG
	NSArray* relationshipKeys			= self.entity.relationshipsByName.allKeys;
	NSMutableArray* missingKeys			= [NSMutableArray array];
	NSMutableArray* relationships		= [NSMutableArray array];
#endif
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if ([attributeKeys containsObject:key]) {
			
			NSAttributeDescription* attribute = attributes[key];
			
			if (!typeCheck || [obj isKindOfClass:classForAttributeType(attribute.attributeType)])
				[self setValue:obj forKey:key];
			
			[attributeKeys removeObject:key];
		}
#ifdef DEBUG
		else if ([relationshipKeys containsObject:key])
			[relationships addObject:key];
		else
			[missingKeys addObject:key];
#endif
	}];
	
#ifdef DEBUG
	NSMutableString* str = [NSMutableString stringWithFormat:@"Populating %@", NSStringFromClass(self.class)];
	
	if (relationships.count)
		[str appendFormat:@"\nRelationship keys found but not populated: %@", [relationships componentsJoinedByString:@" "]];
	
	if (missingKeys.count)
		[str appendFormat:@"\nUnused keys: %@", [missingKeys componentsJoinedByString:@" "]];
	
	OGCoreDataStackLog(@"%@", str);
#endif
}

@end
