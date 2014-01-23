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
	[self deleteDataInContext:[NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue]];
	
	[super tearDown];
}

#pragma mark - Logic Tests

- (void)testInsert
{
	NSManagedObjectContext* context = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 1, @"");
	
	[self deleteDataInContext:context];
}

- (void)testDelete
{
	NSManagedObjectContext* context = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 1, @"");
	
	[context deleteFromEntity:Person.class withRequest:nil];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 0, @"");
}

- (void)testFetch
{
	NSManagedObjectContext* context = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:1 inContext:context];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 1, @"");
	
	[self seedPeople:5 inContext:context];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 6, @"");
	
	[self deleteDataInContext:context];
}

- (void)testPassObjects
{
	NSManagedObjectContext* context		 = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSManagedObjectContext* otherContext = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyBackgroundQueue];
	
	[otherContext observeSavesInContext:context];
	[self seedPeople:1 inContext:context];
	
	[otherContext performBlock:^{
		
		Person* person = [otherContext fetchFromEntity:Person.class withRequest:nil].firstObject;
		
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
	NSManagedObjectContext* context		 = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSManagedObjectContext* otherContext = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyBackgroundQueue];
	
	[otherContext observeSavesInContext:context];
	[self deleteDataInContext:context];
	[self seedPeople:3 inContext:context];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 3, @"");
	
	[otherContext performBlockAndWait:^{
		
		XCTAssertTrue([otherContext countEntity:Person.class withRequest:nil] == 3, @"");
	}];
	[context performBlockAndWait:^{
		
		XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 3, @"");
		
		[context createObjectForEntity:Person.class];
		[context save];
	}];
	[otherContext performBlockAndWait:^{
		
		XCTAssertTrue([otherContext countEntity:Person.class withRequest:nil] == 4, @"");
	}];
	
	[self deleteDataInContext:context];
	[otherContext stopObservingSavesInContext:context];
}

- (void)testFetchRequest
{
	NSManagedObjectContext* context = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:5 inContext:context];
	
	NSArray* objects = [context fetchFromEntity:Person.class withRequest:^(NSFetchRequest *request) {
		
		[request addSortKey:@"name" ascending:YES];
		[request addSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"wallet.cash" ascending:NO]];
		[request setPredicateWithFormat:@"%@ != nil", @"name"];
		
	}];
	
	XCTAssertTrue(objects.count == 5, @"");
	
	[self deleteDataInContext:context];
}

- (void)testResetPersistentStore
{
	NSManagedObjectContext* context = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	[self seedPeople:8 inContext:context];
	
	XCTAssertTrue([context countEntity:Person.class withRequest:nil] == 8, @"");
	XCTAssertTrue([NSPersistentStoreCoordinator reset], @"");
	XCTAssertTrue([[NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue] countEntity:Person.class withRequest:nil] == 0, @"");
}

- (void)testPopulateWithDictionary
{
	NSManagedObjectContext* context = [NSManagedObjectContext newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	Person* person					= [context createObjectForEntity:Person.class];
	NSString* name					= @"bob";
	NSNumber* age					= @55;
	
	XCTAssertFalse([person.name isEqualToString:name], @"");
	
	[person populateWithDictionary:@{@"name": name, @"age": age} options:OGCoreDataStackPopulationOptionBatchNotifications];
	
	XCTAssertTrue([person.name isEqualToString:name], @"");
	XCTAssertTrue([person.age isEqualToNumber:age], @"");
	
	[person populateWithDictionary:@{@"name": NSNull.null, @"age": NSNull.null} options:0];
	
	XCTAssertTrue(!person.name, @"");
	XCTAssertTrue(!person.age, @"");
	
	[context save];
	[self deleteDataInContext:context];
}

#pragma mark - Helpers

- (void)seedPeople:(NSInteger)count inContext:(NSManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		for (NSInteger i = 0; i < count; i++) {
			
			NSString* name	= [NSString stringWithFormat:@"person %li", (long)i];
			Person* person	= [context createObjectForEntity:Person.class];
			
			[person setName:name];
		}
		
		[context save];
	}];
}

- (void)deleteDataInContext:(NSManagedObjectContext *)context
{
	[context performBlockAndWait:^{
		
		[context deleteFromEntity:Person.class withRequest:nil];
		[context deleteFromEntity:Wallet.class withRequest:nil];
		[context deleteFromEntity:Creditcard.class withRequest:nil];
		
		if (context.persistentStoreCoordinator.persistentStores.count)
			[context save];
	}];
}

@end
