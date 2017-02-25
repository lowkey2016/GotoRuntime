//
//  NSObject+HGCRuntime.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "NSObject+HGCRuntime.h"
#import <objc/runtime.h>

#import "HGCUnregisteredClass.h"
#import "HGCMethod.h"
#import "HGCIvar.h"
#import "HGCProperty.h"

@implementation NSObject (HGCRuntime)


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - Create and Destroy Class

+ (HGCUnregisteredClass *)hgc_createUnregisteredSubclassNamed:(NSString *)name {
    return [HGCUnregisteredClass unregisteredClassWithName:name withSuperclass:self];
}

+ (Class)hgc_createSubclassNamed:(NSString *)name {
    return [[self hgc_createUnregisteredSubclassNamed:name] registerClass];
}

+ (void)hgc_destroyClass {
    /*
     objc_disposeClassPair函数用于销毁一个类，不过需要注意的是，如果程序运行中还存在类或其子类的实例，则不能针对类调用该方法。
     */
    objc_disposeClassPair(self);
}

#pragma mark - Set/Get Class

- (Class)hgc_class {
    return object_getClass(self);
}

- (Class)hgc_setClass:(Class)newClass {
    return object_setClass(self, newClass);
}

+ (BOOL)hgc_isMetaClass {
    return class_isMetaClass(self);
}

#pragma mark - Subclasses

+ (NSArray *)hgc_subclasses {
    Class *buffer = NULL;
    
    int count, size;
    do
    {
        count = objc_getClassList(NULL, 0);
        buffer = realloc(buffer, count * sizeof(*buffer));
        size = objc_getClassList(buffer, count);
    } while(size != count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < count; i++)
    {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass)
        {
            if(superclass == self)
            {
                [array addObject: candidate];
                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    free(buffer);
    return array;
}

+ (BOOL)hgc_isSubclassOfClass:(Class)cls {
    return [self isSubclassOfClass:cls];
}

#pragma mark - Super Class

+ (Class)hgc_superClass {
    return class_getSuperclass(self);
}

#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (Class)hgc_setSuperclass:(Class)newSuperclass {
    return class_setSuperclass(self, newSuperclass);
}
#pragma clang diagnostic pop

#pragma mark - Instance

+ (size_t)hgc_instanceSize {
    return class_getInstanceSize(self);
}


///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Method

+ (NSArray<HGCMethod *> *)hgc_methods {
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++) {
        [array addObject: [HGCMethod methodWithObjCMethod:methods[i]]];
    }
    
    free(methods);
    return array;
}

+ (HGCMethod *)hgc_methodForSelector:(SEL)sel {
    Method m = class_getInstanceMethod(self, sel);
    if (!m) return nil;
    
    return [HGCMethod methodWithObjCMethod:m];
}

+ (void)hgc_addMethod:(HGCMethod *)method {
    class_addMethod(self, [method selector], [method implementation], [[method signature] UTF8String]);
}

///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - ivar

+ (NSArray<HGCIvar *> *)hgc_ivars {
    unsigned int count;
    Ivar *list = class_copyIvarList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++) {
        [array addObject:[HGCIvar ivarWithObjCIvar:list[i]]];
    }
    
    free(list);
    return array;
}

+ (HGCIvar *)hgc_ivarForName:(NSString *)name {
    Ivar ivar = class_getInstanceVariable(self, [name UTF8String]);
    if(!ivar) return nil;
    return [HGCIvar ivarWithObjCIvar:ivar];
}


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - Property

+ (NSArray *)hgc_properties {
    unsigned int count;
    objc_property_t *list = class_copyPropertyList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[HGCProperty propertyWithObjCProperty:list[i]]];
    
    free(list);
    return array;
}

+ (HGCProperty *)hgc_propertyForName:(NSString *)name {
    objc_property_t property = class_getProperty(self, [name UTF8String]);
    if(!property) return nil;
    return [HGCProperty propertyWithObjCProperty:property];
}

+ (BOOL)hgc_addProperty:(HGCProperty *)property {
    return [property addToClass:self];
}

@end
