//
//  Wallet.h
//  OGObjectLayerProject
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Creditcard, Person;

@interface Wallet : NSManagedObject

@property (nonatomic, retain) NSNumber * cash;
@property (nonatomic, retain) NSSet *creditcards;
@property (nonatomic, retain) Person *person;
@end

@interface Wallet (CoreDataGeneratedAccessors)

- (void)addCreditcardsObject:(Creditcard *)value;
- (void)removeCreditcardsObject:(Creditcard *)value;
- (void)addCreditcards:(NSSet *)values;
- (void)removeCreditcards:(NSSet *)values;

@end
