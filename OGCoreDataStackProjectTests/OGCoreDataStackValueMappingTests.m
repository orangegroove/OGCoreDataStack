//
//  OGCoreDataStackValueMappingTests.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 08/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStackTestHelper.h"
#import "OGCoreDataStackCore.h"
#import "NSManagedObject+OGCoreDataStackValueMapping.h"
#import "Person.h"
#import "Wallet.h"

@interface OGCoreDataStackValueMappingTests : XCTestCase

@end

@implementation OGCoreDataStackValueMappingTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [NSPersistentStoreCoordinator og_reset];
    
    [super tearDown];
}

- (void)testMapValues
{
    NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
    NSDictionary* dictionary		= @{@"name": @"Dictionary Name"};
    Person* person					= [Person og_createObjectInContext:context];
    
    XCTAssert(![person.name isEqualToString:dictionary[@"name"]], @"");
    [person og_mapAttributeValuesFromSource:dictionary mapper:nil];
    XCTAssert([person.name isEqualToString:dictionary[@"name"]], @"");
}

- (void)testCreateAndMapObject
{
    NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
    NSDictionary* dictionary		= @{@"id": @4, @"name": @"Dictionary Name"};
    
    Person* person = [Person og_objectFromSource:dictionary mapper:nil context:context respectUniqueId:NO];
    XCTAssert([person.name isEqualToString:dictionary[@"name"]], @"");
    XCTAssert([person.id isEqualToNumber:dictionary[@"id"]], @"");
}

- (void)testCreateAndMapObjectsWithUniqueId
{
    NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
    NSArray* dictionaries			= @[@{@"id": @6, @"name": @"Dictionary Name 1"}, @{@"id": @6, @"name": @"Dictionary Name 2"}];
    
    NSArray* persons = [Person og_objectsFromSources:dictionaries mapper:nil context:context respectUniqueId:YES];
    XCTAssert(persons.count == 1, @"");
}

- (void)testCreateAndMapObjectsWithoutUniqueId
{
    NSManagedObjectContext* context	= [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
    NSArray* dictionaries			= @[@{@"cash": @60}, @{@"cash": @60}];
    
    NSArray* wallets = [Wallet og_objectsFromSources:dictionaries mapper:nil context:context respectUniqueId:NO];
    XCTAssert(wallets.count == 2, @"");
}

@end
