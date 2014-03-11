//
//  Person.h
//  OGObjectLayerProject
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import "OGManagedObject.h"

@class Wallet;

@interface Person : OGManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Wallet *wallet;

@end
