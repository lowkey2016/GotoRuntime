//
//  NSObject+HGCCallMethod.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "NSObject+HGCCallMethod.h"
#import "NSObject+HGCRuntime.h"
#import "HGCMethod.h"

@implementation NSObject (HGCCallMethod)

- (id)hgc_sendMethod:(HGCMethod *)method, ... {
    NSParameterAssert([[method signature] hasPrefix:[NSString stringWithUTF8String:@encode(id)]]);
    
    id retVal = nil;
    
    va_list args;
    va_start(args, method);
    [method returnValue:&retVal sendToTarget:self arguments:args];
    va_end(args);
    
    return retVal;
}

- (void)hgc_returnValue:(void *)retPtr sendMethod:(HGCMethod *)method, ... {
    va_list args;
    va_start(args, method);
    [method returnValue:retPtr sendToTarget:self arguments:args];
    va_end(args);
}

- (id)hgc_sendSelector:(SEL)sel, ... {
    HGCMethod *method = [[self hgc_class] hgc_methodForSelector:sel];
    NSParameterAssert([[method signature] hasPrefix:[NSString stringWithUTF8String:@encode(id)]]);
    
    id retVal = nil;
    
    va_list args;
    va_start(args, sel);
    [method returnValue:&retVal sendToTarget:self arguments:args];
    va_end(args);
    
    return retVal;
}

- (void)hgc_returnValue:(void *)retPtr sendSelector:(SEL)sel, ... {
    HGCMethod *method = [[self hgc_class] hgc_methodForSelector:sel];
    va_list args;
    va_start(args, sel);
    [method returnValue:retPtr sendToTarget:self arguments:args];
    va_end(args);
}

@end
