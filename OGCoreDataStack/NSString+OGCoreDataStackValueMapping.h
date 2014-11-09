//
//  NSString+OGCoreDataStackValueMapping.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

@import CoreData;

/*
 Extensions to NSString.
 */

@interface NSString (OGCoreDataStackValueMapping)

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
