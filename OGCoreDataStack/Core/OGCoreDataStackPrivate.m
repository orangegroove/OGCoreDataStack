//
//  OGCoreDataStackPrivate.m
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

#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

#pragma mark - Public

NSURL* _ogMomdURL(void)
{
	NSArray* urls = [[NSBundle bundleWithIdentifier:[NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]] URLsForResourcesWithExtension:@"momd" subdirectory:nil];
	
	NSCAssert(urls.count == 1, @"Create Managed Object Model Error: Looking for 1 Momd in main bundle, found %lu", (unsigned long)urls.count);
	
	return urls.firstObject;
}

NSURL* _ogPersistentStoreURL(NSString* storeType)
{
	if ([storeType isEqualToString:NSInMemoryStoreType])
		return nil;
	
	NSString* filename	= _ogMomdURL().lastPathComponent;
	NSString* modelname	= [filename substringWithRange:NSMakeRange(0, filename.length-5)];
	NSArray* urls		= [NSFileManager.defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
	
	if ([storeType isEqualToString:NSSQLiteStoreType])
		modelname = [modelname stringByAppendingString:@".sqlite"];
	else if ([storeType isEqualToString:NSBinaryStoreType])
		modelname = [modelname stringByAppendingString:@".bin"];
	
	return [urls.lastObject URLByAppendingPathComponent:modelname];
}

//Class _ogClassForAttributeType(NSAttributeType attributeType)
//{
//	switch (attributeType) {
//		case NSInteger16AttributeType:
//		case NSInteger32AttributeType:
//		case NSInteger64AttributeType:
//		case NSFloatAttributeType:
//		case NSDoubleAttributeType:
//		case NSBooleanAttributeType:
//			return NSNumber.class;
//			
//		case NSDecimalAttributeType:
//			return NSDecimalNumber.class;
//			
//		case NSStringAttributeType:
//			return NSString.class;
//			
//		case NSDateAttributeType:
//			return NSDate.class;
//			
//		case NSBinaryDataAttributeType:
//			return NSData.class;
//			
//		case NSUndefinedAttributeType:
//			return NSNull.class;
//	}
//	
//	return nil;
//}
//
//NSMutableArray* _ogTranslatedPopulationDictionaries(Class entity, NSArray* dictionaries)
//{
//	NSMutableArray* translatedDictionaries = [NSMutableArray array];
//	
////	for (NSMutableDictionary* dictionary in dictionaries)
////		[translatedDictionaries addObject:[entity translatedPopulationDictionary:dictionary]];
//	
//	return translatedDictionaries;
//}
//
//NSMutableArray*	_ogIdsForEntity(Class entity, NSArray* translatedDictionaries)
//{
//	NSMutableArray* ids = [NSMutableArray array];
//	NSString* attribute	= [entity uniqueIdAttributeName];
//	
//	for (NSMutableDictionary* dictionary in translatedDictionaries) {
//		
//		id obj = dictionary[attribute];
//		
//		if (obj)
//			[ids addObject:obj];
//	}
//	
//	return ids;
//}
//
//NSMutableDictionary* _ogPopulationDictionaryMatchingId(Class entity, NSArray* dictionaries, id uniqueId)
//{
//	if (!uniqueId)
//		return nil;
//	
//	NSString* attribute	= [entity uniqueIdAttributeName];
//	
//	for (NSMutableDictionary* dictionary in dictionaries)
//		if ([uniqueId isEqual:dictionary[attribute]])
//			return dictionary;
//	
//	return nil;
//}
//
//NSString* _ogCamelCasedFromUnderscoredString(NSString* underScoredString)
//{
//	NSMutableString* string = [NSMutableString stringWithString:underScoredString];
//	NSRange range			= [string rangeOfString:@"_"];
//	
//	while (range.length > 0) {
//		
//		NSString* letter = nil;
//		
//		if (range.location && range.location < string.length-1) {
//			
//			letter			= [string substringWithRange:NSMakeRange(range.location+1, 1)];
//			range.length	= 2;
//		}
//		
//		[string replaceCharactersInRange:range withString:letter? letter.uppercaseString : @""];
//		
//		range = [string rangeOfString:@"_"];
//	}
//	
//	return [NSString stringWithString:string];
//}
//
//void _ogSortObjectsOfAfterId(Class entity, NSMutableArray* objects)
//{
//	NSString* attributeName				= [entity uniqueIdAttributeName];
//	NSDictionary* attributes			= ((NSManagedObject *)objects.firstObject).entity.attributesByName;
//	NSAttributeDescription* attribute	= attributes[attributeName];
//	
//	switch (attribute.attributeType) {
//		case NSInteger16AttributeType:
//		case NSInteger32AttributeType:
//		case NSInteger64AttributeType:
//		case NSDecimalAttributeType:
//		case NSDoubleAttributeType:
//		case NSFloatAttributeType:
//		case NSStringAttributeType:
//		case NSBooleanAttributeType:
//		case NSDateAttributeType:
//			
//			[objects sortUsingSelector:@selector(compare:)];
//			
//			break;
//		case NSObjectIDAttributeType:
//			
//			[objects sortUsingComparator:^NSComparisonResult(NSManagedObjectID* obj1, NSManagedObjectID* obj2) {
//				
//				return [obj1.URIRepresentation.absoluteString compare:obj2.URIRepresentation.absoluteString];
//			}];
//			
//			break;
//		case NSBinaryDataAttributeType:
//			
//			[objects sortUsingComparator:^NSComparisonResult(NSData* obj1, NSData* obj2) {
//				
//				return [[[NSString alloc] initWithData:obj1 encoding:NSUTF8StringEncoding] compare:[[NSString alloc] initWithData:obj2 encoding:NSUTF8StringEncoding]];
//			}];
//			
//			break;
//		case NSTransformableAttributeType: {
//			
//			// If your attribute is of NSTransformableAttributeType, the attributeValueClassName
//			// must be set or attribute value class must implement NSCopying.
//			NSString* className = attribute.userInfo[@"attributeValueClassName"];
//			
//			if (className.length) {
//				
//				
//			}
//			
//			break;
//		}
//		case NSUndefinedAttributeType:
//			break;
//	}
//}
//
//void _ogPopulateObject(id object, NSDictionary* dictionary, OGCoreDataStackPopulationOptions options)
//{
//	BOOL typeCheck				= options & OGCoreDataStackPopulationOptionTypeCheck;
//	NSDictionary* attributes	= ((NSManagedObject *)object).entity.attributesByName;
//	
//	[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		
//		if (!typeCheck || [obj isKindOfClass:_ogClassForAttributeType(((NSAttributeDescription *)attributes[key]).attributeType)])
//			[object setValue:(obj == NSNull.null? nil : obj) forKey:key];
//	}];
//}
//
//void _ogPopulateObjectBatchKVO(id object, NSDictionary* dictionary, OGCoreDataStackPopulationOptions options)
//{
//	BOOL typeCheck				= options & OGCoreDataStackPopulationOptionTypeCheck;
//	NSDictionary* attributes	= ((NSManagedObject *)object).entity.attributesByName;
//	NSMutableSet* accessedAttributes;
//	
//	if (typeCheck) {
//		
//		accessedAttributes = [NSMutableSet set];
//		
//		[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//			
//			NSAttributeDescription* attribute = attributes[key];
//			
//			if (attribute && [obj isKindOfClass:_ogClassForAttributeType(attribute.attributeType)])
//				[accessedAttributes addObject:key];
//		}];
//	}
//	else {
//		
//		accessedAttributes = [NSMutableSet setWithSet:[NSSet setWithArray:attributes.allKeys]];
//		[accessedAttributes intersectSet:[NSSet setWithArray:dictionary.allKeys]];
//	}
//	
//	for (id key in accessedAttributes)
//		[object willChangeValueForKey:key];
//	
//	for (id key in accessedAttributes) {
//		
//		id obj = dictionary[key];
//		[object setPrimitiveValue:(obj == NSNull.null? nil : obj) forKey:key];
//	}
//	
//	for (id key in accessedAttributes)
//		[object didChangeValueForKey:key];
//}
