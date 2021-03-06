//
//  NSManagedObjectContext+OGCoreDataStackContexts.m
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

#import "NSManagedObjectContext+OGCoreDataStackContexts.h"
#import "NSManagedObjectContext+OGCoreDataStack.h"
#import "NSPersistentStoreCoordinator+OGCoreDataStack.h"

@implementation NSManagedObjectContext (OGCoreDataStackContexts)

#pragma mark - Public

+ (instancetype)og_mainQueueContext
{
    static NSManagedObjectContext* context = nil;
    static dispatch_once_t token           = 0;
	
	dispatch_once(&token, ^{
		
        context                            = [[self alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator.og_sharedPersistentStoreCoordinator;
        
		[context og_observeSavesInContext:self.og_backgroundQueueContext];
	});
	
	return context;
}

+ (instancetype)og_backgroundQueueContext
{
    static NSManagedObjectContext* context = nil;
    static dispatch_once_t token           = 0;
	
	dispatch_once(&token, ^{
		
        context                            = [[self alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator.og_sharedPersistentStoreCoordinator;
	});
	
	return context;
}

@end
