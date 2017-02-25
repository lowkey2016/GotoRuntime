//
//  HGCUnregisteredClass.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGCProtocol;
@class HGCIvar;
@class HGCProperty;
@class HGCMethod;

@interface HGCUnregisteredClass : NSObject
{
    Class _class;
}

+ (id)unregisteredClassWithName:(NSString *)name withSuperclass:(Class)superclass;
+ (id)unregisteredClassWithName:(NSString *)name;

- (id)initWithName:(NSString *)name withSuperclass:(Class)superclass;
- (id)initWithName:(NSString *)name;

- (void)addProtocol:(HGCProtocol *)protocol;
- (void)addIvar:(HGCIvar *)ivar;
- (void)addMethod:(HGCMethod *)method;
- (void)addProperty:(HGCProperty *)property;

- (Class)registerClass;

@end
