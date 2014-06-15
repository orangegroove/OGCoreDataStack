//
//  NSString+OGCoreDataStackPopulation.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 14/06/16.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

@interface NSString (OGCoreDataStackPopulation)

/**
 Returns a string with underscores (some_test_string) replaced by camelcasing (someTestString).
 @return The camelcased string.
 */
- (NSString *)og_camelCasedString;

/**
 Returns a string with the intial character capitalized.
 @return The capitalized string.
 */
- (NSString *)og_firstLetterCapitalizedString;

@end
