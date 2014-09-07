//
//  OGCoreDataStackMappingConfiguration.h
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

@interface OGCoreDataStackMappingConfiguration : NSObject

/**
 If YES, dictionary keys named with the underscore pattern (key_name) are automatically mapped to keys with the camelcase pattern (keyName).
 Defaults to YES.
 */
@property (assign, nonatomic) BOOL translateUnderscoreToCamelCase;

/**
 If a dictionary key doesn't match the attribute name, override this method and return the proper name. The default implementation translates keys from underscore to camelcase and returns the key only if it's an attribute or a relationship.
 @param key The dictionary key.
 @param object The object to populate.
 @return The object's property name. If nil is returned, this value is not used to populate the object.
 */
- (NSString *)propertyNameForPopulationKey:(NSString *)key object:(NSManagedObject *)object;

/**
 If a value needs to be transformed before populating an attribute, or a custom action should be performed, this method should be implemented.
 @param object The object to which the attribute belongs.
 @param value The value with which to populate the attribute.
 @note Implement this method for each attribute that needs a custom action or transformation in lieu of a normal assignment. Replace <ATTRIBUTE> with the attribute name.
 */
//- (void)populateObject:(NSManagedObject *)object <ATTRIBUTE>WithValue:(id)value;

/**
 Relationships aren't populated automatically, but if this method is called if implemented.
 @param object The object to which the relationship belongs.
 @param value The value with which to populate the relationship.
 @note Implement this method for each relationships that needs a custom action. Replace <RELATIONSHIP> with the attribute name.
 @note Relationships do not support automatic population. So if this method is not implemented, no action is taken for a relationship, even if there is a corresponding key in the population dictionary.
 */
//- (void)populateObject:(NSManagedObject *)object <RELATIONSHIP>WithValue:(id)value

@end
