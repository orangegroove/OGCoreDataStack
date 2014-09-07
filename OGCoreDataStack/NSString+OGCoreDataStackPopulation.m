//
//  NSString+OGCoreDataStackPopulation.m
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
