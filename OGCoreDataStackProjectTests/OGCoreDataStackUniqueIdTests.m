//
//  OGCoreDataStackUniqueIdTests.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 29/05/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStackTestHelper.h"
#import "OGCoreDataStackCore.h"
#import "Person.h"
#import "NSManagedObject+OGCoreDataStackUniqueId.h"

@interface OGCoreDataStackUniqueIdTests : XCTestCase

@end

@implementation OGCoreDataStackUniqueIdTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
	[NSPersistentStoreCoordinator og_reset];
	
    [super tearDown];
}

- (void)testUniqueId
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	
	XCTAssert(![Person og_objectWithUniqueId:@0 allowNil:YES context:context], @"");
	
	[OGCoreDataStackTestHelper seedPeople:3 inContext:context];
	
	XCTAssert(!![Person og_objectWithUniqueId:@0 allowNil:YES context:context], @"");
	XCTAssert(![Person og_objectWithUniqueId:@10 allowNil:YES context:context], @"");
	
	[OGCoreDataStackTestHelper deleteDataInContext:context];
	
	XCTAssert(![Person og_objectWithUniqueId:@0 allowNil:YES context:context], @"");
	XCTAssert(!![Person og_objectWithUniqueId:@0 allowNil:NO context:context], @"");
}

- (void)testUniqueIdUniqueness
{
	NSManagedObjectContext* context = [NSManagedObjectContext og_newContextWithConcurrency:OGCoreDataStackContextConcurrencyMainQueue];
	NSNumber* thisId				= @77;
	
	[Person og_objectWithUniqueId:thisId allowNil:NO context:context];
	[Person og_objectWithUniqueId:thisId allowNil:NO context:context];
	
	NSUInteger count = [Person og_countWithRequest:^(NSFetchRequest *request) {
		
		request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"id", thisId];
		
	} context:context];
	
	XCTAssert(count == 1, @"");
	
	NSArray* persons = [Person og_objectsWithUniqueIds:[NSSet setWithObjects:thisId, thisId, nil] allowNil:NO context:context];
	
	XCTAssert(persons.count == 1, @"");
}

@end
