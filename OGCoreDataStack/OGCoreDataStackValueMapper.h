//
//  OGCoreDataStackValueMapper.h
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGCoreDataStackCommon.h"
#import "OGCoreDataStackValueMapping.h"

typedef NS_ENUM(uint8_t, OGCoreDataStackValueMapperCastingBehaviour)
{
    OGCoreDataStackValueMapperCastingBehaviourNone,
    OGCoreDataStackValueMapperCastingBehaviourLoose,
    OGCoreDataStackValueMapperCastingBehaviourStrict
};

@interface OGCoreDataStackValueMapper : NSObject <OGCoreDataStackValueMapping>

/**
 
 */
@property (assign, nonatomic, getter=isTransformingUnderscoreToCamelCase) BOOL transformingUnderscoreToCamelCase;

/**
 
 */
@property (assign, nonatomic, getter=isInterpretingNullAsNil) BOOL interpretingNullAsNil;

/**
 
 */
@property (assign, nonatomic) OGCoreDataStackValueMapperCastingBehaviour castingBehaviour;

@end
