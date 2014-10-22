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
	NSManagedObjectContext* mainThreadContext		= NSManagedObjectContext.og_mainThreadContext;
	NSManagedObjectContext* backgroundThreadContext	= NSManagedObjectContext.og_backgroundThreadContext;
	
	XCTAssertTrue([Person og_countWithRequest:nil context:mainThreadContext] == 0, @"");
	
	[OGCoreDataStackTestHelper seedPeople:3 inContext:backgroundThreadContext];
	[backgroundThreadContext og_save];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:mainThreadContext] == 3, @"");
	
	[OGCoreDataStackTestHelper deleteDataInContext:backgroundThreadContext];
	
	XCTAssertTrue([Person og_countWithRequest:nil context:mainThreadContext] == 0, @"");
}

@end
