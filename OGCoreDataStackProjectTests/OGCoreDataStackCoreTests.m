//
//  OGObjectLayerProjectTests.m
//  OGObjectLayerProjectTests
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStackCore.h"
#import "OGCoreDataStackTestHelper.h"
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
	[NSPersistentStoreCoordinator og_reset];
	
	[super tearDown];
}

#pragma mark - Logic Tests

- (void)testInsert
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	[OGCoreDataStackTestHelper seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 1, @"");
}

- (void)testDelete
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	[OGCoreDataStackTestHelper seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 1, @"");
	
	[Person og_deleteWithRequest:nil context:context];

	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 0, @"");
}

- (void)testFetch
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	[OGCoreDataStackTestHelper seedPeople:1 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 1, @"");
	
	[OGCoreDataStackTestHelper seedPeople:5 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 6, @"");
}

- (void)testPassObjects
{
    NSManagedObjectContext* context      = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    NSManagedObjectContext* otherContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	
	[otherContext og_observeSavesInContext:context];
	[OGCoreDataStackTestHelper seedPeople:1 inContext:context];
	
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
	
	[otherContext og_stopObservingSavesInContext:context];
}

- (void)testFetchRequest
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	[OGCoreDataStackTestHelper seedPeople:5 inContext:context];
	
	NSArray* objects = [Person og_fetchWithRequest:^(NSFetchRequest *request) {
		
		[request og_addSortKey:@"name" ascending:YES];
		[request og_addSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"wallet.cash" ascending:NO]];
		
		request.predicate = [NSPredicate predicateWithFormat:@"%@ != nil", @"name"];
		
	} context:context];
	
	XCTAssertTrue(objects.count == 5, @"");
}

- (void)testResetPersistentStore
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	[OGCoreDataStackTestHelper seedPeople:8 inContext:context];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 8, @"");
	XCTAssertTrue([NSPersistentStoreCoordinator og_reset], @"");
	
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:context] == 0, @"");
}

@end
