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
}

- (void)tearDown
{
	[self deleteDataInContext:[NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue]];
	
	[super tearDown];
}

#pragma mark - Logic Tests

- (void)testInsert
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 1, @"");
	
	[self deleteDataInContext:context];
}

- (void)testDelete
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 1, @"");
	
	[Person og_deleteWithRequest:nil context:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 0, @"");
}

- (void)testFetch
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 1, @"");
	
	[self seedPeople:5 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 6, @"");
	
	[self deleteDataInContext:context];
}

- (void)testPassObjects
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSManagedObjectContext* otherContext = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyBackgroundQueue];
	
	[otherContext og_observeSavesInContext:context];
	[self seedPeople:1 inContext:context];
	
	[otherContext performBlock:^{
		
		Person* person				= [Person og_fetchWithRequest:nil context:otherContext].firstObject;
		NSManagedObjectID* objectID	= person.objectID;
		
		XCTAssertEqualObjects(person.managedObjectContext, otherContext, @"");
		
		[context og_performBlock:^(NSArray *objects) {
			
			XCTAssertTrue(objects.count == 1, @"");
			
			Person* passedPerson = objects.firstObject;
			
			XCTAssertEqualObjects(passedPerson.managedObjectContext, context, @"");
			XCTAssertEqualObjects(objectID, passedPerson.objectID, @"");
			
		} passObjects:@[person]];
	}];
	
	[self deleteDataInContext:context];
	[otherContext og_stopObservingSavesInContext:context];
}

- (void)testContextRelationship
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSManagedObjectContext* otherContext = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyBackgroundQueue];
	
	[otherContext og_observeSavesInContext:context];
	[self deleteDataInContext:context];
	[self seedPeople:3 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 3, @"");
	
	[otherContext performBlockAndWait:^{
		
		XCTAssertTrue([Person og_countWithRequest:nil context:otherContext] == 3, @"");
	}];
	[context performBlockAndWait:^{
		
		XCTAssertTrue([Person og_countWithRequest:nil context:context] == 3, @"");
		
		[Person og_createObjectInContext:context];
		[context og_save];
	}];
	[otherContext performBlockAndWait:^{
		
		XCTAssertTrue([Person og_countWithRequest:nil context:otherContext] == 4, @"");
	}];
	
	[self deleteDataInContext:context];
	[otherContext og_stopObservingSavesInContext:context];
}

- (void)testFetchRequest
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:5 inContext:context];
	
	NSArray* objects = [Person og_fetchWithRequest:^(NSFetchRequest *request) {
		
		[request og_addSortKey:@"name" ascending:YES];
		[request og_addSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"wallet.cash" ascending:NO]];
		
		request.predicate = [NSPredicate predicateWithFormat:@"%@ != nil", @"name"];
		
	} context:context];
	
	XCTAssertTrue(objects.count == 5, @"");
	
	[self deleteDataInContext:context];
}

- (void)testResetPersistentStore
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:8 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 8, @"");
	XCTAssertTrue([NSPersistentStoreCoordinator og_reset], @"");
	XCTAssertTrue([Person og_countWithRequest:nil context:[NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue]] == 0, @"");
}

#pragma mark - Helpers

- (void)seedPeople:(NSInteger)count inContext:(NSManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		for (NSInteger i = 0; i < count; i++) {
			
			NSString* name	= [NSString stringWithFormat:@"person %li", (long)i];
			Person* person	= [Person og_createObjectInContext:context];
			
			[person setName:name];
		}
		
		[context og_save];
	}];
}

- (void)deleteDataInContext:(NSManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		[Person og_deleteWithRequest:nil context:context];
		[Wallet og_deleteWithRequest:nil context:context];
		[Creditcard og_deleteWithRequest:nil context:context];
		
		if (context.persistentStoreCoordinator.persistentStores.count)
			[context og_save];
	}];
}

@end
