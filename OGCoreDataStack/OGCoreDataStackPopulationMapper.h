//
//  OGCoreDataStackPopulationMapper.h
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

#import "OGCoreDataStackCommon.h"

@interface OGCoreDataStackPopulationMapper : NSObject

/**
 If YES, dictionary keys named with the underscore pattern (key_name) are automatically mapped to keys with the camelcase pattern (keyName).
 Defaults to YES.
 */
@property (assign, nonatomic) BOOL translateUnderscoreToCamelCase;

#pragma mark - Population
/** @name Population */

/**
 Populates the object with values from the dictionary. Keys that do not match an attribute are ignored, as are attributes without matching keys.
 @param object The object to populate.
 @param dictionary The dictionary containing values.
 @warning All objects must belong to the same context.
 @note Call inside -performBlock: for appropriate context.
 @note To set an attribute to nil, pass an NSNull object.
 */
- (void)populateObject:(NSManagedObject *)object withDictionary:(NSDictionary *)dictionary;

/**
 Populates objects with values from dictionaries.
 @param objects The objects to populate.
 @param dictionaries The dictionaries containing values.
 @note Call inside -performBlock: for appropriate context.
 @note The number of objects and the number of dictionaries must match.
 */
- (void)populateObjects:(NSArray *)objects withDictionaries:(NSArray *)dictionaries;

#pragma mark - Creation
/** @name Creation */

/**
 Creates an object and populates it with values from a dictionary.
 @param class The class of the object to create.
 @param dictionary The dictionary containing values.
 @return The created and populated object.
 @note This method obeys +og_uniqueIdAttributeName and doesn't create duplicates. If the class doesn't have a unique id, no check for duplicates is made.
 */
- (id)createObjectOfClass:(Class)class withDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;

/**
 Creates objecs and populates them with values from dictionaries.
 @param class The class of the objects to create.
 @param dictionaries The dictionaries containing values.
 @return The created and populated objects.
 @note This method obeys +og_uniqueIdAttributeName and doesn't create duplicates. If the class doesn't have a unique id, no check for duplicates is made.
 */
- (NSArray *)createObjectsOfClass:(Class)class withDictionaries:(NSArray *)dictionaries context:(NSManagedObjectContext *)context;

#pragma mark - Configuration
/** @name Configuration */

/**
 This method is used for translating keys in a population dictionary to matching attributes. It shouldn't be overridden if the keys match the attribute names.
 @param key The dictionary key.
 @return The attribute name that should be populated by the corresponding value in the dictionary.
 @note There's no need to override this method to simply translate a key from underscored to camelcase.
 @note The super implementation returns the key parameter.
 */
- (NSString *)attributeNameForPopulationKey:(NSString *)key;

/**
 If there is a corresponding key in the dictionary that should NOT populate an attribute, this method should return YES.
 @param dictionary The population dictionary.
 @return Whether the attribute should be populated.
 @note Implement this method for each attribute that should be skipped. Replace <ATTRIBUTE> with the attribute name. The first letter should be capitalized, even if the attribute name isn't.
 */
//- (BOOL)skipPopulating<ATTRIBUTE>AttributeForDictionary:(NSDictionary *)dictionary;

/**
 If a value needs to be transformed before populating an attribute, or a custom action should be performed, this method should be implemented.
 @param value The value with which to populate the attribute.
 @note Implement this method for each attribute that needs a custom action or transformation in lieu of a normal assignment. Replace <ATTRIBUTE> with the attribute name.
 */
//- (void)populateObject:(id)object <ATTRIBUTE>WithValue:(id)value;

@end
