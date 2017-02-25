//
//  HGCMethod.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "HGCMethod.h"
#import <stdarg.h>


///////////////////////////////////////////////////////////////////////////////////////////


@interface _HGCObjCMethod : HGCMethod
{
    Method _m;
}
@end

@implementation _HGCObjCMethod

- (id)initWithObjCMethod:(Method)method {
    self = [super init];
    if(self) {
        _m = method;
    }
    return self;
}

- (SEL)selector {
    return method_getName(_m);
}

- (IMP)implementation {
    return method_getImplementation(_m);
}

- (NSString *)signature {
    return [NSString stringWithUTF8String:method_getTypeEncoding(_m)];
}

- (void)setImplementation:(IMP)newImp {
    method_setImplementation(_m, newImp);
}

@end


///////////////////////////////////////////////////////////////////////////////////////////


@interface _HGCComponentsMethod : HGCMethod
{
    SEL _sel;
    IMP _imp;
    NSString *_sig;
}
@end

@implementation _HGCComponentsMethod

- (id)initWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature {
    self = [super init];
    if(self) {
        _sel = sel;
        _imp = imp;
        _sig = [signature copy];
    }
    return self;
}

- (void)dealloc {
    [_sig release];
    [super dealloc];
}

- (SEL)selector {
    return _sel;
}

- (IMP)implementation {
    return _imp;
}

- (NSString *)signature {
    return _sig;
}

- (void)setImplementation:(IMP)newImp {
    _imp = newImp;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////


@interface HGCMethod ()

@end

@implementation HGCMethod

#pragma mark - Init

+ (id)methodWithObjCMethod:(Method)method {
    return [[[self alloc] initWithObjCMethod:method] autorelease];
}

+ (id)methodWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature {
    return [[[self alloc] initWithSelector:sel implementation:imp signature:signature] autorelease];
}

- (id)initWithObjCMethod:(Method)method {
    [self release];
    return [[_HGCObjCMethod alloc] initWithObjCMethod:method];
}

- (id)initWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature {
    [self release];
    return [[_HGCComponentsMethod alloc] initWithSelector:sel implementation:imp signature:signature];
}

#pragma mark - NSObject Methods

- (NSString *)description {
    return [NSString stringWithFormat: @"<class = %@, self = %p, sel = %@ imp = %p, sign = %@>", [self class], self, NSStringFromSelector([self selector]), [self implementation], [self signature]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[HGCMethod class]] &&
    [self selector] == [other selector] &&
    [self implementation] == [other implementation] &&
    [[self signature] isEqual: [other signature]];
}

- (NSUInteger)hash {
    return (NSUInteger)(void *)[self selector] ^ (NSUInteger)[self implementation] ^ [[self signature] hash];
}

#pragma mark - Components of Method

- (SEL)selector {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (NSString *)selectorName {
    return NSStringFromSelector([self selector]);
}

- (IMP)implementation {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (NSString *)signature {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)setImplementation:(IMP)newImp {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Call

- (id)sendToTarget:(id)target, ... {
    NSParameterAssert([[self signature] hasPrefix:[NSString stringWithUTF8String:@encode(id)]]);
    
    id retVal = nil;
    
    va_list args;
    va_start(args, target);
    [self returnValue:&retVal sendToTarget:target arguments:args];
    va_end(args);
    
    return retVal;
}

- (void)returnValue:(void *)retPtr sendToTarget:(id)target, ... {
    va_list args;
    va_start(args, target);
    [self returnValue:retPtr sendToTarget:target arguments:args];
    va_end(args);
}

- (void)returnValue:(void *)retPtr sendToTarget:(id)target arguments:(va_list)args {
    NSMethodSignature *signature = [target methodSignatureForSelector:[self selector]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argumentCount = [signature numberOfArguments];
    
    [invocation setTarget:target];
    [invocation setSelector:[self selector]];
    for (NSUInteger i = 2; i < argumentCount; i++) { // 跳过 target 和 _cmd 前面两个参数，本质上是 objc_msgSend(target, _cmd, args)
        int cookie = va_arg(args, int);
        if (cookie != HGC_ARG_MAGIC_COOKIE) {
            NSLog(@"%s: incorrect magic cookie %08x; did you forget to use HGCARG() around your arguments?", __func__, cookie);
            abort();
        }
        const char *typeStr = va_arg(args, char *);
        void *argPtr = va_arg(args, void *);
        
        // NSGetSizeAndAlignment:
        // Obtains the actual size and the aligned size of an encoded type.
        
        NSUInteger inSize;
        NSGetSizeAndAlignment(typeStr, &inSize, NULL);
        NSUInteger sigSize;
        NSGetSizeAndAlignment([signature getArgumentTypeAtIndex:i], &sigSize, NULL);
        
        if (inSize != sigSize) {
            NSLog(@"%s: size mismatch between passed-in argument and required argument; in type: %s (%lu) requested: %s (%lu)", __func__, typeStr, (long)inSize, [signature getArgumentTypeAtIndex: i], (long)sigSize);
            abort();
        }
        
        [invocation setArgument:argPtr atIndex:i];
    }
    
    [invocation invoke];
    
    if ([signature methodReturnLength] && retPtr) {
        [invocation getReturnValue:retPtr];
    }
}

@end
