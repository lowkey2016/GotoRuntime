//
//  HGCProperty.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "HGCProperty.h"

NSString * const HGCPropertyTypeEncodingAttribute                  = @"T";
NSString * const HGCPropertyBackingIVarNameAttribute               = @"V";
NSString * const HGCPropertyCopyAttribute                          = @"C";
NSString * const HGCPropertyCustomGetterAttribute                  = @"G";
NSString * const HGCPropertyCustomSetterAttribute                  = @"S";
NSString * const HGCPropertyDynamicAttribute                       = @"D";
NSString * const HGCPropertyEligibleForGarbageCollectionAttribute  = @"P";
NSString * const HGCPropertyNonAtomicAttribute                     = @"N";
NSString * const HGCPropertyOldTypeEncodingAttribute               = @"t";
NSString * const HGCPropertyReadOnlyAttribute                      = @"R";
NSString * const HGCPropertyRetainAttribute                        = @"&";
NSString * const HGCPropertyWeakReferenceAttribute                 = @"W";


///////////////////////////////////////////////////////////////////////////////////////////


@interface _HGCObjCProperty : HGCProperty
{
    objc_property_t _property;
    NSMutableDictionary *_attrs;
    NSString *_name;
}
@end

@implementation _HGCObjCProperty

#pragma mark - Init

- (id)initWithObjCProperty:(objc_property_t)property {
    self = [super init];
    if (self) {
        _property = property;
        NSArray *attrPairs = [[NSString stringWithUTF8String:property_getAttributes(property)] componentsSeparatedByString:@","];
        _attrs = [[NSMutableDictionary alloc] initWithCapacity:[attrPairs count]];
        for (NSString *attrPair in attrPairs) {
            [_attrs setObject:[attrPair substringFromIndex:1] forKey:[attrPair substringToIndex:1]];
        }
    }
    return self;
}

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        _name = [name copy];
        _attrs = [attributes copy];
    }
    return self;
}

- (void)dealloc {
    [_attrs release];
    [_name release];
    [super dealloc];
}

- (NSString *)name {
    if (_property) {
        return [NSString stringWithUTF8String:property_getName(_property)];
    }
    else {
        return _name;
    }
}

- (NSDictionary *)attributes {
    return [[_attrs copy] autorelease];
}

- (BOOL)addToClass:(Class)classToAddTo {
    NSDictionary *attrs = [self attributes];
    objc_property_attribute_t *cattrs = (objc_property_attribute_t *)calloc([attrs count], sizeof(objc_property_attribute_t));
    unsigned attrIdx = 0;
    for (NSString *attrCode in attrs) {
        cattrs[attrIdx].name = [attrCode UTF8String];
        cattrs[attrIdx].value = [[attrs objectForKey:attrCode] UTF8String];
        attrIdx++;
    }
    BOOL result = class_addProperty(classToAddTo,
                                    [[self name] UTF8String],
                                    cattrs,
                                    (unsigned int)[attrs count]);
    free(cattrs);
    return result;
}

- (NSString *)attributeEncodings {
    NSMutableArray *filteredAttributes = [NSMutableArray arrayWithCapacity:[_attrs count] - 2];
    for (NSString *attrKey in _attrs) {
        if (![attrKey isEqualToString:HGCPropertyTypeEncodingAttribute] && ![attrKey isEqualToString:HGCPropertyBackingIVarNameAttribute])
        {
            [filteredAttributes addObject:[_attrs objectForKey:attrKey]];
        }
    }
    return [filteredAttributes componentsJoinedByString: @","];
}

- (BOOL)hasAttribute:(NSString *)code {
    return [_attrs objectForKey:code] != nil;
}

- (HGCPropertySetterSemantics)setterSemantics {
    if ([self hasAttribute:HGCPropertyCopyAttribute]) return HGCPropertySetterSemanticsCopy;
    if ([self hasAttribute:HGCPropertyRetainAttribute]) return HGCPropertySetterSemanticsRetain;
    return HGCPropertySetterSemanticsAssign;
}

- (BOOL)isReadOnly {
    return [self hasAttribute:HGCPropertyReadOnlyAttribute];
}

- (BOOL)isNonAtomic {
    return [self hasAttribute:HGCPropertyNonAtomicAttribute];
}

- (BOOL)isDynamic {
    return [self hasAttribute:HGCPropertyDynamicAttribute];
}

- (BOOL)isWeakReference {
    return [self hasAttribute:HGCPropertyWeakReferenceAttribute];
}

- (BOOL)isEligibleForGarbageCollection {
    return [self hasAttribute:HGCPropertyEligibleForGarbageCollectionAttribute];
}

- (NSString *)contentOfAttribute:(NSString *)code {
    return [_attrs objectForKey:code];
}

- (SEL)customGetter {
    return NSSelectorFromString([self contentOfAttribute:HGCPropertyCustomGetterAttribute]);
}

- (SEL)customSetter {
    return NSSelectorFromString([self contentOfAttribute:HGCPropertyCustomSetterAttribute]);
}

- (NSString *)typeEncoding {
    return [self contentOfAttribute:HGCPropertyTypeEncodingAttribute];
}

- (NSString *)oldTypeEncoding {
    return [self contentOfAttribute:HGCPropertyOldTypeEncodingAttribute];
}

- (NSString *)ivarName {
    return [self contentOfAttribute:HGCPropertyBackingIVarNameAttribute];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////


@implementation HGCProperty

#pragma mark - Create

+ (id)propertyWithObjCProperty:(objc_property_t)property {
    return [[[self alloc] initWithObjCProperty:property] autorelease];
}

+ (id)propertyWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    return [[[self alloc] initWithName:name attributes:attributes] autorelease];
}

- (id)initWithObjCProperty:(objc_property_t)property {
    [self release];
    return [[_HGCObjCProperty alloc] initWithObjCProperty:property];
}

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    [self release];
    return [[_HGCObjCProperty alloc] initWithName:name attributes:attributes];
}

#pragma mark - NSObject Methods

- (NSString *)description {
    return [NSString stringWithFormat: @"<class = %@, self = %p, name = %@, attr encodings = %@, type encodings = %@, ivar name = %@>", [self class], self, [self name], [self attributeEncodings], [self typeEncoding], [self ivarName]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[HGCProperty class]] &&
    [[self name] isEqual: [other name]] &&
    ([self attributeEncodings] ? [[self attributeEncodings] isEqual:[other attributeEncodings]] : ![other attributeEncodings]) &&
    [[self typeEncoding] isEqual:[other typeEncoding]] &&
    ([self ivarName] ? [[self ivarName] isEqual:[other ivarName]] : ![other ivarName]);
}

- (NSUInteger)hash {
    return [[self name] hash] ^ [[self typeEncoding] hash];
}

- (NSString *)name {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary *)attributes {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)addToClass:(Class)classToAddTo {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (NSString *)attributeEncodings {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (HGCPropertySetterSemantics)setterSemantics {
    [self doesNotRecognizeSelector:_cmd];
    return HGCPropertySetterSemanticsAssign;
}

- (BOOL)isReadOnly {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isNonAtomic {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isDynamic {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isWeakReference {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isEligibleForGarbageCollection {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (SEL)customGetter {
    [self doesNotRecognizeSelector:_cmd];
    return (SEL)0;
}

- (SEL)customSetter {
    [self doesNotRecognizeSelector:_cmd];
    return (SEL)0;
}

- (NSString *)typeEncoding {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)oldTypeEncoding {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)ivarName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
