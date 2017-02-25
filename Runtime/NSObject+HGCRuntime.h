//
//  NSObject+HGCRuntime.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGCUnregisteredClass;
@class HGCMethod;
@class HGCIvar;
@class HGCProperty;

@interface NSObject (HGCRuntime)

/** Class 相关 */

+ (HGCUnregisteredClass *)hgc_createUnregisteredSubclassNamed:(NSString *)name;
+ (Class)hgc_createSubclassNamed:(NSString *)name;
+ (void)hgc_destroyClass;

// Apple likes to fiddle with -class to hide their dynamic subclasses
// e.g. KVO subclasses, so [obj class] can lie to you
// rt_class is a direct call to object_getClass (which in turn
// directly hits up the isa) so it will always tell the truth
- (Class)hgc_class;
- (Class)hgc_setClass:(Class)newClass;
+ (BOOL)hgc_isMetaClass;

// 包括自己
+ (NSArray *)hgc_subclasses;
+ (BOOL)hgc_isSubclassOfClass:(Class)cls;

+ (Class)hgc_superClass;
+ (Class)hgc_setSuperclass:(Class)newSuperclass;

+ (size_t)hgc_instanceSize;

/** Method 相关 */

+ (NSArray<HGCMethod *> *)hgc_methods;
+ (HGCMethod *)hgc_methodForSelector:(SEL)sel;
+ (void)hgc_addMethod:(HGCMethod *)method;

/** ivar 相关 */

+ (NSArray<HGCIvar *> *)hgc_ivars;
+ (HGCIvar *)hgc_ivarForName:(NSString *)name;

/** Propery 相关 */

+ (NSArray<HGCProperty *> *)hgc_properties;
+ (HGCProperty *)hgc_propertyForName:(NSString *)name;
+ (BOOL)hgc_addProperty:(HGCProperty *)property;

@end
