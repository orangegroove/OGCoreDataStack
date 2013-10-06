//
//  OGObjectLayerProjectTests.m
//  OGObjectLayerProjectTests
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStack.h"
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
	[self deleteData];
	
	[super tearDown];
}

#pragma mark - Logic Tests

- (void)testInsert
{
	[self seedPeople:1];
	
	XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 1, @"");
	
	[self deleteData];
}

- (void)testDelete
{
	[self seedPeople:1];
	
	[Person deleteWithRequest:nil context:[NSManagedObjectContext mainContext]];
	
	XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 0, @"");
}

- (void)testFetch
{
	[self seedPeople:1];
	
	XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 1, @"");
	
	[self seedPeople:5];
	
	XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 6, @"");
	
	[self deleteData];
}

- (void)testPassObjects
{
	[self seedPeople:1];
	
	NSManagedObjectContext* mainContext	= [NSManagedObjectContext mainContext];
	NSManagedObjectContext* workContext	= [NSManagedObjectContext workContext];
	
	[workContext performBlock:^{
		
		Person* person				= [Person fetchSingleWithRequest:nil context:workContext];
		NSManagedObjectID* objectID	= person.objectID;
		
		XCTAssertEqualObjects(person.managedObjectContext, workContext, @"");
		
		[mainContext performBlock:^(NSArray *objects) {
			
			XCTAssertTrue(objects.count == 1, @"");
			
			Person* passedPerson = objects[0];
			
			XCTAssertEqualObjects(passedPerson.managedObjectContext, mainContext, @"");
			XCTAssertEqualObjects(objectID, passedPerson.objectID, @"");
			
		} passObjects:@[person]];
	}];
	
	[self deleteData];
}

- (void)testContextRelationship
{
	NSManagedObjectContext* mainContext	= [NSManagedObjectContext mainContext];
	NSManagedObjectContext* workContext	= [NSManagedObjectContext workContext];
	
	[self seedPeople:3];
	[workContext performBlockAndWait:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:workContext] == 3, @"");
	}];
	[mainContext performBlockAndWait:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:mainContext] == 3, @"");
		
		[Person insertInContext:mainContext];
		[mainContext save];
	}];
	[workContext performBlockAndWait:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:mainContext] == 4, @"");
	}];
	
	[self deleteData];
}

- (void)testAsyncDelete
{
	[self seedPeople:3];
	
	[Person asynchronouslyDeleteWithRequest:nil completion:^{
		
		XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 0, @"");
	}];
}

- (void)testAsyncCount
{
	[self seedPeople:5];
	
	[Person asynchronouslyCountWithRequest:nil completion:^(NSUInteger count) {
		
		XCTAssertTrue(count == 5, @"");
		
		[self deleteData];
	}];
}

- (void)testAsyncFetch
{
	[self seedPeople:4];
	
	[Person asynchronouslyFetchWithRequest:nil completion:^(NSArray *objects) {
		
		XCTAssertTrue(objects.count == 4, @"");
		
		[self deleteData];
	}];
}

- (void)testFetchRequest
{
	[self seedPeople:5];
	
	NSArray* objects = [Person fetchWithRequest:^(NSFetchRequest *request) {
		
		[request addSortKey:@"name" ascending:YES];
		[request addSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"wallet.cash" ascending:NO]];
		[request setPredicateWithFormat:@"%@ != nil", @"name"];
		
	} context:[NSManagedObjectContext mainContext]];
	
	XCTAssertTrue(objects.count == 5, @"");
	
	[self deleteData];
}

- (void)testResetPersistentStore
{
	[self seedPeople:8];
	
	XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 8, @"");
	XCTAssertTrue([NSPersistentStoreCoordinator clearPersistentStore], @"");
	XCTAssertTrue([Person countWithRequest:nil context:[NSManagedObjectContext mainContext]] == 0, @"");
}

- (void)testPopulateWithDictionary
{
	Person* person					= [Person insertInContext:[NSManagedObjectContext mainContext]];
	NSMutableDictionary* dictionary	= [NSMutableDictionary dictionaryWithObject:@"bob" forKey:@"name"];
	
	XCTAssertFalse([@"bob" isEqualToString:person.name], @"");
	
	[person populateWithDictionary:dictionary typeCheck:YES];
	
	XCTAssertTrue([@"bob" isEqualToString:person.name], @"");
	
	[[NSManagedObjectContext mainContext] save];
	[self deleteData];
}

#pragma mark - Helpers

- (void)seedPeople:(NSInteger)count
{
	NSManagedObjectContext* context = [NSManagedObjectContext workContext];
	
	[context performBlockAndWait:^{
		
		for (NSInteger i = 0; i < count; i++) {
			
			NSString* name	= [NSString stringWithFormat:@"person %i", i];
			Person* person	= [Person insertInContext:context];
			
			[person setName:name];
		}
		
		[context save];
	}];
}

- (void)deleteData
{
	NSManagedObjectContext* context	= [NSManagedObjectContext workContext];
	
	[context performBlockAndWait:^{
		
		[Person deleteWithRequest:nil context:context];
		[Wallet deleteWithRequest:nil context:context];
		[Creditcard deleteWithRequest:nil context:context];
		
		[context save];
	}];
}

@end
