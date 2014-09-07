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
    /**
     No attempts at automatic conversion.
     */
    OGCoreDataStackValueMapperCastingBehaviourNone,
    
    /**
     Attempts automatic conversion, and sets the uncasted value on failure.
     */
    OGCoreDataStackValueMapperCastingBehaviourLoose,
    
    /**
     Attempts automatic conversion, and sets nil on casting failure.
     */
    OGCoreDataStackValueMapperCastingBehaviourStrict
};

@interface OGCoreDataStackValueMapper : NSObject <OGCoreDataStackValueMapping>

/**
 Transforms underscored key names (e.g. some_key) to camel case (i.e., someKey).
 */
@property (assign, nonatomic, getter=isTransformingUnderscoreToCamelCase) BOOL transformingUnderscoreToCamelCase;

/**
 If NSNull is supplied, it is treated as a nil value.
 */
@property (assign, nonatomic, getter=isInterpretingNullAsNil) BOOL interpretingNullAsNil;

/**
 Automatic type conversions.
 */
@property (assign, nonatomic) OGCoreDataStackValueMapperCastingBehaviour castingBehaviour;

@end
