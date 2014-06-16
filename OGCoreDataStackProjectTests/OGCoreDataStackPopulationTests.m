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
#import "NSManagedObject+OGCoreDataStackPopulation.h"
#import "Person.h"
#import "Wallet.h"

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
	
	XCTAssert(![person.name isEqualToString:dictionary[@"name"]], @"");
	[person og_populateWithDictionary:dictionary];
	XCTAssert([person.name isEqualToString:dictionary[@"name"]], @"");
}

- (void)testPopulateCreateObject
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSDictionary* dictionary		= @{@"id": @4, @"name": @"Dictionary Name"};
	
	Person* person = [Person og_createObjectInContext:context populateWithDictionary:dictionary];
	XCTAssert([person.name isEqualToString:dictionary[@"name"]], @"");
	XCTAssert([person.id isEqualToNumber:dictionary[@"id"]], @"");
}

- (void)testPopulateCreateObjectsWithUniqueId
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSArray* dictionaries			= @[@{@"id": @6, @"name": @"Dictionary Name 1"}, @{@"id": @6, @"name": @"Dictionary Name 2"}];
	
	NSArray* persons = [Person og_createObjectsInContext:context populateWithDictionaries:dictionaries];
	XCTAssert(persons.count == 1, @"");
}

- (void)testPopulateCreateObjectsWithoutUniqueId
{
	NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSArray* dictionaries			= @[@{@"cash": @60}, @{@"cash": @60}];
	
	NSArray* wallets = [Wallet og_createObjectsInContext:context populateWithDictionaries:dictionaries];
	XCTAssert(wallets.count == 2, @"");
}

@end
