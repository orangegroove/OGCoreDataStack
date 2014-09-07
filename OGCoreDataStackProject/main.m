//
//  main.m
//  OGObjectLayerProject
//
//  Created by Jesper on 8/16/13.
//  Copyright (c) 2013 Orange Groove. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGAppDelegate.h"


@interface TestObj : NSObject
@property (strong,nonatomic) NSString* myString;
@end
@implementation TestObj
@end

int main(int argc, char * argv[])
{
    TestObj* obj = [[TestObj alloc] init];
    [obj setValue:@2 forKey:@"myString"];
    
    exit(0);
    
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([OGAppDelegate class]));
	}
}
