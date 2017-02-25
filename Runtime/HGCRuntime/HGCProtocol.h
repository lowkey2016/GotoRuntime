//
//  HGCProtocol.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class HGCMethod;

@interface HGCProtocol : NSObject
{
}

+ (NSArray<HGCProtocol *> *)allProtocols;

+ (id)protocolWithObjCProtocol:(Protocol *)protocol;
+ (id)protocolWithName:(NSString *)name;

- (id)initWithObjCProtocol:(Protocol *)protocol;
- (id)initWithName:(NSString *)name;

- (Protocol *)objCProtocol;
- (NSString *)name;
- (NSArray<HGCProtocol *> *)incorporatedProtocols; // Protocol 本身遵循的所有协议集合
- (NSArray<HGCMethod *> *)methodsRequired:(BOOL)isRequiredMethod instance:(BOOL)isInstanceMethod;

@end
