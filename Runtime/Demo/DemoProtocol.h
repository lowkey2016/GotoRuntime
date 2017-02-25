//
//  DemoProtocol.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DemoProtocol <NSObject, NSCopying>

+ (void)requiredClassMethod;
- (void)requiredInstanceMethod;

@optional
+ (void)optionalClassMethod;
- (void)optionalInstanceMethod;

@end
