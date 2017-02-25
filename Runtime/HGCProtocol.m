//
//  HGCProtocol.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "HGCProtocol.h"
#import "HGCMethod.h"


///////////////////////////////////////////////////////////////////////////////////////////


@interface _HGCObjCProtocol : HGCProtocol
{
    Protocol *_protocol;
}
@end

@implementation _HGCObjCProtocol

- (id)initWithObjCProtocol:(Protocol *)protocol
{
    self = [super init];
    if (self) {
        _protocol = protocol;
    }
    return self;
}

- (Protocol *)objCProtocol {
    return _protocol;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////


@implementation HGCProtocol

#pragma mark - Create

+ (id)protocolWithObjCProtocol:(Protocol *)protocol {
    return [[[self alloc] initWithObjCProtocol:protocol] autorelease];
}

+ (id)protocolWithName:(NSString *)name {
    return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithObjCProtocol:(Protocol *)protocol {
    [self release];
    return [[_HGCObjCProtocol alloc] initWithObjCProtocol:protocol];
}

- (id)initWithName:(NSString *)name {
    return [self initWithObjCProtocol:objc_getProtocol([name cStringUsingEncoding:[NSString defaultCStringEncoding]])];
}

#pragma mark - NSObject Methods

- (NSString *)description {
    return [NSString stringWithFormat: @"<class = %@, self = %p, name = %@>", [self class], self, [self name]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[HGCProtocol class]] &&
    protocol_isEqual([self objCProtocol], [other objCProtocol]);
}

- (NSUInteger)hash {
    return [[self objCProtocol] hash];
}

#pragma mark - Get Protocol

- (Protocol *)objCProtocol {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)name {
    return [NSString stringWithUTF8String:protocol_getName([self objCProtocol])];
}

+ (NSArray<HGCProtocol *> *)allProtocols {
    unsigned int count;
    Protocol **protocols = objc_copyProtocolList(&count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++) {
        [array addObject: [[[self alloc] initWithObjCProtocol:protocols[i]] autorelease]];
    }
    
    free(protocols);
    return array;
}

- (NSArray<HGCProtocol *> *)incorporatedProtocols {
    unsigned int count;
    Protocol **protocols = protocol_copyProtocolList([self objCProtocol], &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++) {
        [array addObject:[HGCProtocol protocolWithObjCProtocol:protocols[i]]];
    }
    
    free(protocols);
    return array;
}

- (NSArray<HGCMethod *> *)methodsRequired:(BOOL)isRequiredMethod instance:(BOOL)isInstanceMethod {
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList([self objCProtocol], isRequiredMethod, isInstanceMethod, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++) {
        NSString *signature = [NSString stringWithCString:methods[i].types encoding:[NSString defaultCStringEncoding]];
        [array addObject: [HGCMethod methodWithSelector:methods[i].name implementation:NULL signature:signature]];
    }
    
    free(methods);
    return array;
}

@end
