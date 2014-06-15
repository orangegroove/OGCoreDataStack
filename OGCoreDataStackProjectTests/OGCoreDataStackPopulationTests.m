//
//  OGCoreDataStackPopulationTests.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 14/06/15.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStackTestHelper.h"
#import "OGCoreDataStackCore.h"
#import "Person.h"
#import "Wallet.h"
#import "OGCoreDataStackPopulationMapper.h"

@interface OGCoreDataStackPopulationTests : XCTestCase

@end

@implementation OGCoreDataStackPopulationTests

- (void)setUp
{
	[super setUp];
}

- (void)tearDown
{
	[NSPersistentStoreCoordinator og_reset];
	
	[super tearDown];
}

- (void)testPopulateObject
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSDictionary* dictionary		= @{@"name": @"Dictionary Name"};
	Person* person					= [Person og_createObjectInContext:context];
	
	OGCoreDataStackPopulationMapper* mapper = [[OGCoreDataStackPopulationMapper alloc] init];
	
	XCTAssert(![person.name isEqualToString:dictionary[@"name"]], @"");
	[mapper populateObject:person withDictionary:dictionary];
	XCTAssert([person.name isEqualToString:dictionary[@"name"]], @"");
}

- (void)testPopulateCreateObject
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSDictionary* dictionary		= @{@"id": @4, @"name": @"Dictionary Name"};
	
	OGCoreDataStackPopulationMapper* mapper = [[OGCoreDataStackPopulationMapper alloc] init];
	
	Person* person = [mapper createObjectOfClass:Person.class withDictionary:dictionary context:context];
	XCTAssert([person.name isEqualToString:dictionary[@"name"]], @"");
	XCTAssert([person.id isEqualToNumber:dictionary[@"id"]], @"");
}

- (void)testPopulateCreateObjectsWithUniqueId
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSArray* dictionaries			= @[@{@"id": @6, @"name": @"Dictionary Name 1"}, @{@"id": @6, @"name": @"Dictionary Name 2"}];
	
	OGCoreDataStackPopulationMapper* mapper = [[OGCoreDataStackPopulationMapper alloc] init];
	
	NSArray* persons = [mapper createObjectsOfClass:Person.class withDictionaries:dictionaries context:context];
	
	NSLog(@"%@", persons);
	
	XCTAssert(persons.count == 1, @"");
}

- (void)testPopulateCreateObjectsWithoutUniqueId
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSArray* dictionaries			= @[@{@"cash": @60}, @{@"cash": @60}];
	
	OGCoreDataStackPopulationMapper* mapper = [[OGCoreDataStackPopulationMapper alloc] init];
	
	NSArray* wallets = [mapper createObjectsOfClass:Wallet.class withDictionaries:dictionaries context:context];
	XCTAssert(wallets.count == 2, @"");
}

@end
