//
//  DemoObject.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "DemoObject.h"
#import <stdarg.h>

@implementation DemoObject

- (void)hello {
    NSLog(@"hello");
}

- (int)world:(int)x {
    NSLog(@"%s ** x = %zd", __func__, x);
    return x * 2;
}

- (void)hello:(NSString *)name world:(NSInteger)cnt {
    NSLog(@"%s ** %@ has %zd millions.", __func__, name, cnt);
}

- (void)helloworld:(NSInteger)x, ... {
    va_list args;
    va_start(args, x);
    [self _helloworld:args];
    va_end(args);
}

- (void)_helloworld:(va_list)args {
    NSMethodSignature *sign = [self methodSignatureForSelector:@selector(helloworld:)];
    NSUInteger argumentCount = [sign numberOfArguments];
    NSLog(@"arguments count = %zd", argumentCount); // 不能读取到可变参数的个数
    void *cur = va_arg(args, void *);
    int count = 0;
    while (cur) {
        NSLog(@"%d ** cur = %p", count, cur);
        count++;
//        NSString *type = [NSString stringWithUTF8String:@encode(typeof(cur))];
//        if ([type isEqualToString:@"c"]) {
//            char *t = (char *)cur;
//            NSLog(@"char: %c", *t);
//        }
//        else if ([type isEqualToString:@"i"]) {
//            int *t = (int *)cur;
//            NSLog(@"int: %zd\n", *t);
//        }
//        else if ([type isEqualToString:@"l"]) {
//            long *t = (long *)cur;
//            NSLog(@"long: %zd\n", *t);
//        }
//        else if ([type isEqualToString:@"q"]) {
//            long long *t = (long long *)cur;
//            NSLog(@"long long: %zd\n", *t);
//        }
//        else if ([type isEqualToString:@"f"]) {
//            float *t = (float *)cur;
//            NSLog(@"float: %f\n", *t);
//        }
//        else if ([type isEqualToString:@"d"]) {
//            double *t = (double *)cur;
//            NSLog(@"double: %f\n", *t);
//        }
//        else if ([type isEqualToString:@"B"]) {
//            BOOL *t = (BOOL *)cur;
//            NSLog(@"BOOL: %zd", *t);
//        }
//        else if ([type isEqualToString:@"*"]) {
//            char **t = (char **)cur;
//            NSLog(@"char *: %s", *t);
//        }
//        else if ([type isEqualToString:@"@"]) {
//            id *t = (id *)cur;
//            NSLog(@"object: %@", *t);
//        }
//        else if ([type isEqualToString:@":"]) {
//            SEL *t = (SEL *)cur;
//            NSLog(@"selector: %@", NSStringFromSelector(*t));
//        }
//        else if ([type isEqualToString:@"#"]) {
//            Class *t = (Class *)cur;
//            NSLog(@"class: %@", *t);
//        }
//        else {
//            NSLog(@"cant read");
//        }
        cur = va_arg(args, void *);
    }
}

- (int)dlorw:(int)y {
    NSLog(@"%s ** y = %zd", __func__, y);
    return y * 4;
}

+ (void)world {
    NSLog(@"%s ** world", __func__);
}

+ (void)dlrow {
    NSLog(@"%s ** dlrow", __func__);
}

#pragma mark - DemoProtocol

+ (void)requiredClassMethod {
    return;
}

- (void)requiredInstanceMethod {
    return;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] init];
}

@end
