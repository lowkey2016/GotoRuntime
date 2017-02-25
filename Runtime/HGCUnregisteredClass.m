//
//  HGCUnregisteredClass.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "HGCUnregisteredClass.h"
#import <objc/runtime.h>

#import "HGCProtocol.h"
#import "HGCIvar.h"
#import "HGCProperty.h"
#import "HGCMethod.h"

@implementation HGCUnregisteredClass

#pragma mark - Create

+ (id)unregisteredClassWithName:(NSString *)name withSuperclass:(Class)superclass {
    return [[[self alloc] initWithName:name withSuperclass:superclass] autorelease];
}

+ (id)unregisteredClassWithName:(NSString *)name {
    return [self unregisteredClassWithName:name withSuperclass:Nil];
}

- (id)initWithName:(NSString *)name withSuperclass:(Class)superclass {
    self = [super init];
    if (self) {
        /*
        objc_allocateClassPair函数：如果我们要创建一个根类，则superclass指定为Nil。extraBytes通常指定为0，该参数是分配给类和元类对象尾部的索引ivars的字节数。
        
        为了创建一个新类，我们需要调用objc_allocateClassPair。然后使用诸如class_addMethod，class_addIvar等函数来为新创建的类添加方法、实例变量和属性等。完成这些后，我们需要调用objc_registerClassPair函数来注册类，之后这个新类就可以在程序中使用了。
        
        实例方法和实例变量应该添加到类自身上，而类方法应该添加到类的元类上。
         */
        _class = objc_allocateClassPair(superclass, [name UTF8String], 0);
        if (_class == Nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    return [self initWithName:name withSuperclass:Nil];
}

#pragma mark - Add

- (void)addProtocol:(HGCProtocol *)protocol {
    class_addProtocol(_class, [protocol objCProtocol]);
}

- (void)addIvar:(HGCIvar *)ivar {
    const char *typeStr = [[ivar typeEncoding] UTF8String];
    NSUInteger size, alignment;
    NSGetSizeAndAlignment(typeStr, &size, &alignment);
    class_addIvar(_class, [[ivar name] UTF8String], size, log2(alignment), typeStr);
}

- (void)addMethod:(HGCMethod *)method {
    class_addMethod(_class, [method selector], [method implementation], [[method signature] UTF8String]);
}

- (void)addProperty:(HGCProperty *)property {
    [property addToClass:_class];
}

#pragma mark - Register

- (Class)registerClass {
    objc_registerClassPair(_class);
    return _class;
}

@end
