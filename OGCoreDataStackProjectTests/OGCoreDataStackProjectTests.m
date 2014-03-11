//
//  OGObjectLayerProjectTests.m
//  OGObjectLayerProjectTests
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStackCore.h"
#import "Person.h"
#import "Wallet.h"
#import "Creditcard.h"

@interface OGObjectLayerProjectTests : XCTestCase

@end

@implementation OGObjectLayerProjectTests

#pragma mark - Lifecycle

- (void)setUp
{
	[super setUp];
	
#ifndef DEBUG
#define DEBUG 1
#endif
}

- (void)tearDown
{
	[self deleteDataInContext:[OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue]];
	
	[super tearDown];
}

#pragma mark - Logic Tests

- (void)testInsert
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 1, @"");
	
	[self deleteDataInContext:context];
}

- (void)testDelete
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 1, @"");
	
	[Person deleteWithRequest:nil context:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 0, @"");
}

- (void)testFetch
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 1, @"");
	
	[self seedPeople:5 inContext:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 6, @"");
	
	[self deleteDataInContext:context];
}

- (void)testPassObjects
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	OGManagedObjectContext* otherContext = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyBackgroundQueue];
	
	[otherContext observeSavesInContext:context];
	[self seedPeople:1 inContext:context];
	
	[otherContext performBlock:^{
		
		Person* person				= [Person fetchWithRequest:nil context:otherContext].firstObject;
		NSManagedObjectID* objectID	= person.objectID;
		
		XCTAssertEqualObjects(person.managedObjectContext, otherContext, @"");
		
		[context performBlock:^(NSArray *objects) {
			
			XCTAssertTrue(objects.count == 1, @"");
			
			Person* passedPerson = objects.firstObject;
			
			XCTAssertEqualObjects(passedPerson.managedObjectContext, context, @"");
			XCTAssertEqualObjects(objectID, passedPerson.objectID, @"");
			
		} passObjects:@[person]];
	}];
	
	[self deleteDataInContext:context];
	[otherContext stopObservingSavesInContext:context];
}

- (void)testContextRelationship
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	OGManagedObjectContext* otherContext = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyBackgroundQueue];
	
	[otherContext observeSavesInContext:context];
	[self deleteDataInContext:context];
	[self seedPeople:3 inContext:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 3, @"");
	
	[otherContext performBlockAndWait:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:otherContext] == 3, @"");
	}];
	[context performBlockAndWait:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:context] == 3, @"");
		
		[Person createObjectInContext:context];
		[context save];
	}];
	[otherContext performBlockAndWait:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:otherContext] == 4, @"");
	}];
	
	[self deleteDataInContext:context];
	[otherContext stopObservingSavesInContext:context];
}

- (void)testFetchRequest
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:5 inContext:context];
	
	NSArray* objects = [Person fetchWithRequest:^(NSFetchRequest *request) {
		
		[request addSortKey:@"name" ascending:YES];
		[request addSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"wallet.cash" ascending:NO]];
		
		request.predicate = [NSPredicate predicateWithFormat:@"%@ != nil", @"name"];
		
	} context:context];
	
	XCTAssertTrue(objects.count == 5, @"");
	
	[self deleteDataInContext:context];
}

- (void)testResetPersistentStore
{
	OGManagedObjectContext* context = [OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:8 inContext:context];
	
	XCTAssertTrue([Person countWithRequest:nil context:context] == 8, @"");
	XCTAssertTrue([OGPersistentStoreCoordinator reset], @"");
	XCTAssertTrue([Person countWithRequest:nil context:[OGManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue]] == 0, @"");
}

#pragma mark - Helpers

- (void)seedPeople:(NSInteger)count inContext:(OGManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		for (NSInteger i = 0; i < count; i++) {
			
			NSString* name	= [NSString stringWithFormat:@"person %li", (long)i];
			Person* person	= [Person createObjectInContext:context];
			
			[person setName:name];
		}
		
		[context save];
	}];
}

- (void)deleteDataInContext:(OGManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		[Person deleteWithRequest:nil context:context];
		[Wallet deleteWithRequest:nil context:context];
		[Creditcard deleteWithRequest:nil context:context];
		
		if (context.persistentStoreCoordinator.persistentStores.count)
			[context save];
	}];
}

@end
