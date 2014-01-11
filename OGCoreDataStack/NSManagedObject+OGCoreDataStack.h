//
//  NSManagedObject+OGCoreDataStack.h
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

@import CoreData;
#import "OGCoreDataStackCommon.h"

@interface NSManagedObject (OGCoreDataStack)

/** @name Lifecycle */

/**
 The entity name for this class. Override this if your entity is not named the same as your class.
 @return The entity name in the NSManagedObjectModel.
 @note mogenerator generates this method automatically.
 */
+ (NSString *)entityName;

/** @name Populating */

/**
 Called by populateWithDictionary:typeCheck: to transform keys or values as needed.
 @return The translated dictionary.
 */
- (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary;

/**
 Populates an object with values from a dictionary. Keys in the dictionary must match attributes in the entity.
 @param dictionary The dictionary containing the values.
 @param typeCheck If YES, the types in the dictionary are checked before attempting to set the attribute to be of a compatible class.
 @note Relationships are not supported and must be handled manually.
 */
- (void)populateWithDictionary:(NSMutableDictionary *)dictionary typeCheck:(BOOL)typeCheck;

@end
