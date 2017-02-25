//
//  DemoProObject.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "DemoProObject.h"

@implementation DemoProObject
@dynamic num;

- (void)setProtocl:(id<DemoProtocol>)protocl {
    _protocl = protocl;
}
- (id<DemoProtocol>)protocl {
    return _protocl;
}

@end
