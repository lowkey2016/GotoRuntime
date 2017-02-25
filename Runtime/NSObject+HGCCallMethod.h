//
//  NSObject+HGCCallMethod.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGCMethod;

@interface NSObject (HGCCallMethod)

- (id)hgc_sendMethod:(HGCMethod *)method, ...;
- (void)hgc_returnValue:(void *)retPtr sendMethod:(HGCMethod *)method, ...;

- (id)hgc_sendSelector:(SEL)sel, ...;
- (void)hgc_returnValue:(void *)retPtr sendSelector:(SEL)sel, ...;

@end
