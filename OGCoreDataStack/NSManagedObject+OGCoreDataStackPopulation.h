//
//  NSManagedObject_OGCoreDataStackPopulation.h
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

@interface NSManagedObject (OGCoreDataStackPopulation)

#pragma mark - Configuration

/**
 
 */
+ (Class)og_populationMappingConfigurationClass;

#pragma mark - Creating

/**
 Creates an object and populates it with values from a dictionary.
 @param context The context in which the object will be inserted.
 @param dictionary The dictionary containing values.
 @return The created and populated object.
 @note This method obeys +og_uniqueIdAttributeName and doesn't create duplicates. If the class doesn't have a unique id, no check for duplicates is made.
 */
+ (instancetype)og_createObjectInContext:(NSManagedObjectContext *)context populateWithDictionary:(NSDictionary *)dictionary;

/**
 Creates objecs and populates them with values from dictionaries.
 @param context The context in which the objects will be inserted.
 @param dictionaries The dictionaries containing values.
 @return The created and populated objects.
 @note This method obeys +og_uniqueIdAttributeName and doesn't create duplicates. If the class doesn't have a unique id, no check for duplicates is made.
 */
+ (NSArray *)og_createObjectsInContext:(NSManagedObjectContext *)context populateWithDictionaries:(NSArray *)dictionaries;

#pragma mark - Populating

/**
 Populates the object with values from the dictionary. Keys that do not match an attribute are ignored, as are attributes without matching keys.
 @param dictionary The dictionary containing values.
 @note Call inside -performBlock: for appropriate context.
 @note To set an attribute to nil, pass an NSNull object as a value.
 */
- (void)og_populateWithDictionary:(NSDictionary *)dictionary;

@end
