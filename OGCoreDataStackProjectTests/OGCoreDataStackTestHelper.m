//
//  OGCoreDataStackTestHelper.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 28/05/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGCoreDataStackTestHelper.h"
#import "OGCoreDataStackCore.h"
#import "Person.h"
#import "Wallet.h"
#import "Creditcard.h"

@implementation OGCoreDataStackTestHelper

#pragma mark - Public

+ (void)seedPeople:(NSInteger)count inContext:(NSManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		for (NSInteger i = 0; i < count; i++)
        {
            Person* person = [Person og_createObjectInContext:context];
            person.name    = [NSString stringWithFormat:@"person %li", (long)i];
            person.id      = @(i);
		}
		
		[context og_save];
	}];
}

+ (void)deleteDataInContext:(NSManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		[Person og_deleteWithRequest:nil context:context];
		[Wallet og_deleteWithRequest:nil context:context];
		[Creditcard og_deleteWithRequest:nil context:context];
		
		if (context.persistentStoreCoordinator.persistentStores.count)
        {
            [context og_save];
        }
	}];
}

@end
