//
//  DemoProObject.h
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoProtocol.h"

@interface DemoProObject : NSObject
{
    id<DemoProtocol> _protocl;
}

@property (nonatomic, copy, getter=loadName, setter=saveName:) NSString *name;
@property (retain) NSNumber *num;
@property (nonatomic, readonly, weak) id<DemoProtocol> protocl;
@property (assign) NSInteger count;
@property (strong) NSMutableString *varname;

@end
