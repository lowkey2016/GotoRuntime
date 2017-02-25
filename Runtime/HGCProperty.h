//
//  HGCProperty.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, HGCPropertySetterSemantics) {
    HGCPropertySetterSemanticsAssign,
    HGCPropertySetterSemanticsRetain,
    HGCPropertySetterSemanticsCopy,
};

extern NSString * const HGCPropertyTypeEncodingAttribute;
extern NSString * const HGCPropertyBackingIVarNameAttribute;

extern NSString * const HGCPropertyCopyAttribute;
extern NSString * const HGCPropertyRetainAttribute;
extern NSString * const HGCPropertyCustomGetterAttribute;
extern NSString * const HGCPropertyCustomSetterAttribute;
extern NSString * const HGCPropertyDynamicAttribute;
extern NSString * const HGCPropertyEligibleForGarbageCollectionAttribute;
extern NSString * const HGCPropertyNonAtomicAttribute;
extern NSString * const HGCPropertyOldTypeEncodingAttribute;
extern NSString * const HGCPropertyReadOnlyAttribute;
extern NSString * const HGCPropertyWeakReferenceAttribute;

@interface HGCProperty : NSObject
{
}

+ (id)propertyWithObjCProperty:(objc_property_t)property;
+ (id)propertyWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (id)initWithObjCProperty:(objc_property_t)property;
- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (NSDictionary *)attributes;
- (BOOL)addToClass:(Class)classToAddTo;

- (NSString *)attributeEncodings;
- (BOOL)isReadOnly;
- (HGCPropertySetterSemantics)setterSemantics;
- (BOOL)isNonAtomic;
- (BOOL)isDynamic;
- (BOOL)isWeakReference;
- (BOOL)isEligibleForGarbageCollection;
- (SEL)customGetter;
- (SEL)customSetter;
- (NSString *)name;
- (NSString *)typeEncoding;
- (NSString *)oldTypeEncoding;
- (NSString *)ivarName;

@end
