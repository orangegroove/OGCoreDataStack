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
 
 */
- (NSString *)attributeNameForPopulationKey:(NSString *)key object:(NSManagedObject *)object;

/**
 
 */
- (NSString *)relationshipNameForPopulationKey:(NSString *)key object:(NSManagedObject *)object;

/**
 If a value needs to be transformed before populating an attribute, or a custom action should be performed, this method should be implemented.
 @param value The value with which to populate the attribute.
 @note Implement this method for each attribute that needs a custom action or transformation in lieu of a normal assignment. Replace <ATTRIBUTE> with the attribute name.
 */
//- (void)populateObject:(id)object <ATTRIBUTE>WithValue:(id)value;

/**
 Relationships aren't populated automatically, but if this method is called if implemented.
 @param object
 @param value
 @note Implement this method for each relationships that needs a custom action. Replace <RELATIONSHIP> with the attribute name.
 */
//- (void)populateObject:(NSManagedObject *)object <RELATIONSHIP>WithValue:(id)value

@end
