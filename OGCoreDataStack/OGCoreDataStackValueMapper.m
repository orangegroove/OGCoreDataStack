//
//  OGCoreDataStackValueMapper.m
//  OGCoreDataStackProject
//
//  Created by Jesper on 06/09/14.
//  Copyright (c) 2014 Orange Groove. All rights reserved.
//

#import "OGCoreDataStackValueMapper.h"
#import "NSString+OGCoreDataStackValueMapping.h"

static NSNumber* _ogCastToInt16(id value)
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return @([(NSString *)value intValue]);
    }
    
    return nil;
}

static NSNumber* _ogCastToInt32(id value)
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return @([(NSString *)value intValue]);
    }
    
    return nil;
}

static NSNumber* _ogCastToInt64(id value)
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return @([(NSString *)value longLongValue]);
    }
    
    return nil;
}

static NSDecimalNumber* _ogCastToDecimalNumber(id value)
{
    if ([value isKindOfClass:NSDecimalNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSNumber.class])
    {
        [NSDecimalNumber decimalNumberWithString:[(NSNumber *)value stringValue]];
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return [NSDecimalNumber decimalNumberWithString:value];
    }
    
    return nil;
}

static NSNumber* _ogCastToDouble(id value)
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return @([(NSString *)value doubleValue]);
    }
    
    return nil;
}

static NSNumber* _ogCastToFloat(id value)
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return @([(NSString *)value floatValue]);
    }
    
    return nil;
}

static NSNumber* _ogCastToBool(id value)
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return @([(NSString *)value boolValue]);
    }
    
    if (value)
    {
        return @YES;
    }
    
    if (!value && value != nil)
    {
        return @NO;
    }
    
    return nil;
}

static NSString* _ogCastToString(id value)
{
    if ([value isKindOfClass:NSString.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSNumber.class])
    {
        [(NSNumber *)value stringValue];
    }
    
    return nil;
}

static NSDate* _ogCastToDate(id value)
{
    if ([value isKindOfClass:NSDate.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSNumber.class])
    {
        return [NSDate dateWithTimeIntervalSince1970:((NSNumber *)value).doubleValue];
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return [NSDate dateWithTimeIntervalSince1970:((NSString *)value).doubleValue];
    }
    
    return nil;
}

static NSData* _ogCastToData(id value)
{
    if ([value isKindOfClass:NSData.class])
    {
        return value;
    }
    
    if ([value isKindOfClass:NSString.class])
    {
        return [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([value isKindOfClass:NSNumber.class])
    {
        return [[(NSNumber *)value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

static id _ogTryCast(NSAttributeType type, id value)
{
    switch (type)
    {
        case NSInteger16AttributeType:
        {
            return _ogCastToInt16(value);
        }
        case NSInteger32AttributeType:
        {
            return _ogCastToInt32(value);
        }
        case NSInteger64AttributeType:
        {
            return _ogCastToInt64(value);
        }
        case NSDecimalAttributeType:
        {
            return _ogCastToDecimalNumber(value);
        }
        case NSDoubleAttributeType:
        {
            return _ogCastToDouble(value);
        }
        case NSFloatAttributeType:
        {
            return _ogCastToFloat(value);
        }
        case NSBooleanAttributeType:
        {
            return _ogCastToBool(value);
        }
        case NSStringAttributeType:
        {
            return _ogCastToString(value);
        }
        case NSDateAttributeType:
        {
            return _ogCastToDate(value);
        }
        case NSBinaryDataAttributeType:
        {
            return _ogCastToData(value);
        }
        case NSTransformableAttributeType:
        case NSObjectIDAttributeType:
        case NSUndefinedAttributeType:
        default:
        {
            return nil;
        }
    }
}

@implementation OGCoreDataStackValueMapper

#pragma mark - OGCoreDataStackValueMapping

- (NSString *)og_mappedKeyForDestination:(NSManagedObject *)destination source:(NSDictionary *)source sourceKey:(NSString *)sourceKey
{
    return self.isTransformingUnderscoreToCamelCase? [sourceKey og_camelCasedString] : sourceKey;
}

- (id)og_mappedValue:(id)value fromSource:(NSDictionary *)source sourceKey:(NSString *)sourceKey destination:(NSManagedObject *)destination destinationKey:(NSString *)destinationKey
{
    if (self.isInterpretingNullAsNil && value == NSNull.null)
    {
        value = nil;
    }
    
    if (value && self.castingBehaviour != OGCoreDataStackValueMapperCastingBehaviourNone)
    {
        NSAttributeDescription* description = destination.entity.attributesByName[destinationKey];
        NSAttributeType type                = description.attributeType;
        id castValue                        = _ogTryCast(type, value);
        
        if (self.castingBehaviour == OGCoreDataStackValueMapperCastingBehaviourLoose || castValue)
        {
            value = castValue;
        }
    }
    
    return value;
}

@end
