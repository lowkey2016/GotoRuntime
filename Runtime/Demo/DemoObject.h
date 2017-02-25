//
//  DemoObject.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoProtocol.h"

@interface DemoObject : NSObject <DemoProtocol>
{
    int i;
}

@property (nonatomic, copy) NSString *s;

- (void)hello;
- (int)world:(int)x;
- (void)hello:(NSString *)name world:(NSInteger)cnt;
- (void)helloworld:(NSInteger)x, ...;

- (int)dlorw:(int)y;

+ (void)world;
+ (void)dlrow;

@end
