//
//  HGCIvar.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface HGCIvar : NSObject
{
}

+ (id)ivarWithObjCIvar:(Ivar)ivar;
+ (id)ivarWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding;
+ (id)ivarWithName:(NSString *)name encode:(const char *)encodeStr;

- (id)initWithObjCIvar:(Ivar)ivar;
- (id)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding;

- (NSString *)name;
- (NSString *)typeEncoding;
- (ptrdiff_t)offset;

@end
