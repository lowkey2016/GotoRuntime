//
//  HGCIvar.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "HGCIvar.h"


///////////////////////////////////////////////////////////////////////////////////////////


@interface _HGCObjCIvar : HGCIvar
{
    Ivar _ivar;
}
@end

@implementation _HGCObjCIvar

- (id)initWithObjCIvar:(Ivar)ivar {
    self = [super init];
    if(self) {
        _ivar = ivar;
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithUTF8String:ivar_getName(_ivar)];
}

- (NSString *)typeEncoding {
    return [NSString stringWithUTF8String:ivar_getTypeEncoding(_ivar)];
}

- (ptrdiff_t)offset {
    return ivar_getOffset(_ivar);
}

@end


///////////////////////////////////////////////////////////////////////////////////////////


@interface _HGCComponentsIvar : HGCIvar
{
    NSString *_name;
    NSString *_typeEncoding;
}
@end

@implementation _HGCComponentsIvar

- (id)initWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding {
    self = [super init];
    if (self) {
        _name = [name copy];
        _typeEncoding = [typeEncoding copy];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_typeEncoding release];
    [super dealloc];
}

- (NSString *)name {
    return _name;
}

- (NSString *)typeEncoding {
    return _typeEncoding;
}

- (ptrdiff_t)offset {
    return -1;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////


@implementation HGCIvar

#pragma mark - Create Ivar

+ (id)ivarWithObjCIvar:(Ivar)ivar {
    return [[[self alloc] initWithObjCIvar:ivar] autorelease];
}

+ (id)ivarWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding {
    return [[[self alloc] initWithName:name typeEncoding:typeEncoding] autorelease];
}

+ (id)ivarWithName:(NSString *)name encode:(const char *)encodeStr {
    return [self ivarWithName:name typeEncoding:[NSString stringWithUTF8String:encodeStr]];
}

- (id)initWithObjCIvar:(Ivar)ivar {
    [self release];
    return [[_HGCObjCIvar alloc] initWithObjCIvar:ivar];
}

- (id)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding {
    [self release];
    return [[_HGCComponentsIvar alloc] initWithName:name typeEncoding:typeEncoding];
}

#pragma mark - NSObject Methods

- (NSString *)description {
    return [NSString stringWithFormat: @"<class = %@, self = %p, name = %@, type encoding = %@, offset = %ld>", [self class], self, [self name], [self typeEncoding], (long)[self offset]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[HGCIvar class]] &&
    [[self name] isEqual:[other name]] &&
    [[self typeEncoding] isEqual:[other typeEncoding]];
}

- (NSUInteger)hash {
    return [[self name] hash] ^ [[self typeEncoding] hash];
}

#pragma mark - Getters

- (NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)typeEncoding
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (ptrdiff_t)offset {
    [self doesNotRecognizeSelector: _cmd];
    return 0;
}

@end
