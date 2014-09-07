//
//  Person.m
//  OGObjectLayerProject
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import "Person.h"
#import "Wallet.h"
#import "NSManagedObject+OGCoreDataStackUniqueId.h"

@implementation Person

@dynamic age;
@dynamic id;
@dynamic name;
@dynamic wallet;

+ (NSString *)og_uniqueIdAttributeName
{
	return @"id";
}

@end
