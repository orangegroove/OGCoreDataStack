//
//  NSString+OGCoreDataStackPopulation.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 14/06/16.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "NSString+OGCoreDataStackPopulation.h"

@implementation NSString (OGCoreDataStackPopulation)

- (NSString *)og_camelCasedString
{
	NSMutableString* string = [NSMutableString stringWithString:self];
	NSRange underscoreRange	= [string rangeOfString:@"_"];
	
	while (underscoreRange.location != NSNotFound) {
		
		[string replaceCharactersInRange:underscoreRange withString:@""];
		
		if (string.length >= underscoreRange.location + underscoreRange.length)
			[string replaceCharactersInRange:underscoreRange withString:[[string substringWithRange:underscoreRange] uppercaseString]];
		
		underscoreRange = [string rangeOfString:@"_"];
	}
	
	return [NSString stringWithString:string];
}

- (NSString *)og_firstLetterCapitalizedString
{
	if (self.length < 2)
		return self.uppercaseString;
	
	NSString* first = [self substringToIndex:1];
	NSString* rest	= [self substringFromIndex:1];
	
	return [NSString stringWithFormat:@"%@%@", first.uppercaseString, rest];
}

@end
