//
//  OGCoreDataStackContextTests.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 28/05/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCoreDataStackTestHelper.h"
#import "OGCoreDataStackCore.h"
#import "NSManagedObjectContext+OGCoreDataStackContexts.h"
#import "Person.h"

@interface OGCoreDataStackContextTests : XCTestCase

@end
@implementation OGCoreDataStackContextTests

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

- (void)testContextRelationship
{
    NSManagedObjectContext* mainQueueContext       = NSManagedObjectContext.og_mainQueueContext;
    NSManagedObjectContext* backgroundQueueContext = NSManagedObjectContext.og_backgroundQueueContext;
	
	XCTAssertTrue([Person og_countWithRequest:nil context:mainQueueContext] == 0, @"");
	
	[OGCoreDataStackTestHelper seedPeople:3 inContext:backgroundQueueContext];
	[backgroundQueueContext og_save];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:mainQueueContext] == 3, @"");
	
	[OGCoreDataStackTestHelper deleteDataInContext:backgroundQueueContext];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:mainQueueContext] == 0, @"");
}

@end
