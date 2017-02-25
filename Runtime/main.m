//
//  main.m
//  Runtime
//
//  Created by Jymn_Chen on 2017/2/25.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+HGCRuntime.h"
#import "HGCUnregisteredClass.h"
#import "HGCMethod.h"
#import "HGCProtocol.h"
#import "HGCIvar.h"
#import "HGCProperty.h"

#import "DemoObject.h"
#import "DemoKVOObj.h"
#import "DemoKVOObserver.h"
#import "DemoProtocol.h"
#import "DemoProObject.h"

// log 出所有子类
static void demo_logSubclasses(void) {
    NSArray *subclasses = [NSObject hgc_subclasses];
    NSLog(@"subclasses of NSObject is: %@", subclasses);
    subclasses = [NSString hgc_subclasses];
    NSLog(@"subclasses of NSString is: %@", subclasses);
    subclasses = [NSArray hgc_subclasses];
    NSLog(@"subclasses of NSArray is: %@", subclasses);
}

// 动态创建类
static void demo_createClass(void) {
    Class subclass = [NSObject hgc_createSubclassNamed:@"DemoObject"];
    NSLog(@"create subclass of NSObject: %@", NSStringFromClass(subclass));
    subclass = [NSString hgc_createSubclassNamed:@"DemoString"];
    NSLog(@"create subclass of NSString: %@", NSStringFromClass(subclass));
    [subclass hgc_destroyClass];
}

// 验证 NSObject 元类的闭环关系
static void demo_NSObjectMetaClass(void) {
    Class meta = [NSObject hgc_class];
    NSLog(@"%@ is meta: %zd", NSStringFromClass(meta), [meta hgc_isMetaClass]);
    NSLog(@"NSObject is meta: %zd", [NSObject hgc_isMetaClass]);
    
    Class meta_meta = [meta hgc_class];
    NSLog(@"NSObject meta isa NSObject meta: %zd", meta == meta_meta);
    NSLog(@"NSObject meta is subclass of NSObject: %zd", [meta hgc_isSubclassOfClass:[NSObject class]]);
}

// 验证 KVO 的 isa_swizzling
static void demo_getClassOfKVO(void) {
    DemoKVOObj *obj = [DemoKVOObj new];
    DemoKVOObserver *observer = [DemoKVOObserver new];
    [obj addObserver:observer forKeyPath:@"count" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
//    // 强心关闭 isa_swizzling, KVO 也会被禁用
//    [obj hgc_setClass:[DemoKVOObj class]];
    obj.count = 100;
    
    Class cls = [obj class];
    Class realCls = [obj hgc_class];
    NSLog(@"class = %@, real class = %@", cls, realCls);
    [obj release];
}

// 动态修改超类
static void demo_superClass(void) {
    Class subclass = [NSObject hgc_createSubclassNamed:@"Demo"];
    NSLog(@"is NSString is super class of %@: %zd", NSStringFromClass(subclass), [subclass hgc_isSubclassOfClass:[NSString class]]);
    [subclass hgc_setSuperclass:[NSString class]];
    NSLog(@"is NSString is super class of %@: %zd", NSStringFromClass(subclass), [subclass hgc_isSubclassOfClass:[NSString class]]);
    [subclass hgc_destroyClass];
}

// sizeof 和 instance size
static void demo_instanceSize(void) {
    NSLog(@"sizeof char is %zd bytes", sizeof(char));
    NSLog(@"sizeof short is %zd bytes", sizeof(short));
    NSLog(@"sizeof int is %zd bytes", sizeof(int));
    NSLog(@"sizeof long is %zd bytes", sizeof(long));
    NSLog(@"sizeof long long is %zd bytes", sizeof(long long));
    NSLog(@"sizeof void* is %zd bytes", sizeof(void *));
    NSLog(@"instance size of NSObject is %zd", [NSObject hgc_instanceSize]);
    NSLog(@"instance size of NSObject is equal to sizeof(void *): %zd", ([NSObject hgc_instanceSize] == sizeof(void *)));
}

// 动态修改 isa
static void demo_setClass(void) {
    id obj = [[NSObject alloc] init];
    NSLog(@"obj is kind of NSString: %zd", [obj isKindOfClass:[NSString class]]);
    [obj hgc_setClass:[NSString class]];
    NSLog(@"obj is kind of NSString: %zd", [obj isKindOfClass:[NSString class]]);
    [obj hgc_setClass:[NSObject class]];
    NSLog(@"obj is kind of NSString: %zd", [obj isKindOfClass:[NSString class]]);
    [obj release];
}

// 类型编码探究
// 参考：http://nshipster.cn/type-encodings/
static void demo_typeEncoding(void) {
    /*
     c	A char
     i	An int
     s	A short
     l	A longl is treated as a 32-bit quantity on 64-bit programs.
     q	A long long
     C	An unsigned char
     I	An unsigned int
     S	An unsigned short
     L	An unsigned long
     Q	An unsigned long long
     f	A float
     d	A double
     B	A C++ bool or a C99 _Bool
     v	A void
     *	A character string (char *)
     @	An object (whether statically typed or typed id)
     #	A class object (Class)
     :	A method selector (SEL)
     [array type]	An array
     {name=type...}	A structure
     (name=type...)	A union
     bnum	A bit field of num bits
     ^type	A pointer to type
     ?	An unknown type (among other things, this code is used for function pointers)
     */
    NSLog(@"int        : %s", @encode(int));
    NSLog(@"float      : %s", @encode(float));
    NSLog(@"float *    : %s", @encode(float*));
    NSLog(@"char       : %s", @encode(char));
    NSLog(@"char *     : %s", @encode(char *)); // 指针的标准编码是加一个前置的 ^，而 char * 拥有自己的编码 *。这在概念上是很好理解的，因为 C 的字符串被认为是一个实体，而不是指针。
    NSLog(@"BOOL       : %s", @encode(BOOL)); // BOOL 是 c，而不是某些人以为的 i。原因是 char 比 int 小，且在 80 年代 Objective-C 最开始设计的时候，每一个 bit 位都比今天的要值钱（就像美元一样）。BOOL 更确切地说是 signed char （即使设置了 -funsigned-char 参数），以在不同编译器之间保持一致，因为 char 可以是 signed 或者 unsigned。
    NSLog(@"void       : %s", @encode(void));
    NSLog(@"void *     : %s", @encode(void *));
    
    NSLog(@"NSObject * : %s", @encode(NSObject *));
    NSLog(@"NSObject   : %s", @encode(NSObject)); // 直接传入 NSObject 将产生 #。但是传入 [NSObject class] 产生一个名为 NSObject 只有一个类字段的结构体。很明显，那就是 isa 字段，所有的 NSObject 实例都用它来表示自己的类型。
    NSLog(@"id : %s",         @encode(id));
    NSLog(@"NSString * : %s", @encode(NSString *));
    NSLog(@"[NSObject] : %s", @encode(typeof([NSObject class])));
    NSLog(@"NSError ** : %s", @encode(typeof(NSError **)));
    
    int intArray[5] = {1, 2, 3, 4, 5};
    NSLog(@"int[]      : %s", @encode(typeof(intArray)));
    
    float floatArray[3] = {0.1f, 0.2f, 0.3f};
    NSLog(@"float[]    : %s", @encode(typeof(floatArray)));
    
    typedef struct _struct {
        short a;
        long long b;
        unsigned long long c;
    } Struct;
    NSLog(@"struct     : %s", @encode(typeof(Struct)));
}

// 不带参数的 Method 的 selector, implementation, signature 探究
static void demo_selector1(void) {
    DemoObject *obj = [DemoObject new];
    
    SEL sel = NSSelectorFromString(@"hello");
    Method m = class_getInstanceMethod([DemoObject class], sel);
    
    SEL otherSel = method_getName(m);
    NSLog(@"sel: %@", NSStringFromSelector(otherSel));
    NSLog(@"sel equal: %zd", sel == otherSel);
    
    IMP imp = method_getImplementation(m);
    NSLog(@"imp: %p", imp);
    ((void (*)(id, SEL))(void *) objc_msgSend)(obj, sel);
    
    NSString *sign = [NSString stringWithUTF8String:method_getTypeEncoding(m)];
    NSLog(@"sign: %@", sign);
    
    NSMethodSignature *ms = [obj methodSignatureForSelector:sel];
    NSInvocation *in = [NSInvocation invocationWithMethodSignature:ms];
    [in setTarget:obj];
    [in setSelector:sel];
    [in invoke];
    
    [obj release];
}

// 带一个参数和返回值的 Method 的 selector, implementation, signature 探究
static void demo_selector2(void) {
    DemoObject *obj = [DemoObject new];
    
    SEL sel = NSSelectorFromString(@"world:");
    Method m = class_getInstanceMethod([DemoObject class], sel);
    
    SEL otherSel = method_getName(m);
    NSLog(@"sel: %@", NSStringFromSelector(otherSel));
    NSLog(@"sel equal: %zd", sel == otherSel);
    
    IMP imp = method_getImplementation(m);
    NSLog(@"imp: %p", imp);
    int x = ((int (*)(id, SEL, int))(void *) objc_msgSend)(obj, sel, 100);
    NSLog(@"ret val: %zd", x);
    
    NSString *sign = [NSString stringWithUTF8String:method_getTypeEncoding(m)];
    NSLog(@"sign: %@", sign);
    
    NSMethodSignature *ms = [obj methodSignatureForSelector:sel];
    NSMethodSignature *otherMs = [DemoObject instanceMethodSignatureForSelector:sel];
    NSLog(@"ms equal: %zd", ms == otherMs);
    NSInvocation *in = [NSInvocation invocationWithMethodSignature:ms];
    [in setSelector:sel];
    x = 200;
    [in setArgument:&x atIndex:2];
    [in invokeWithTarget:obj];
    void *ret;
    if ([ms methodReturnLength] && ret) {
        [in getReturnValue:&ret];
        NSLog(@"ret val: %zd", ret);
    }
    
    [obj release];
}

// 带两个参数的 Method 的 selector, implementation, signature 探究
static void demo_selector3(void) {
    DemoObject *obj = [DemoObject new];
    
    SEL sel = @selector(hello:world:);
    Method m = class_getInstanceMethod([DemoObject class], sel);
    
    SEL otherSel = method_getName(m);
    NSLog(@"sel: %@", NSStringFromSelector(otherSel));
    NSLog(@"sel equal: %zd", sel == otherSel);
    
    IMP imp = method_getImplementation(m);
    NSLog(@"imp: %p", imp);
    ((void (*)(id, SEL, NSString *, NSInteger))(void *) objc_msgSend)(obj, sel, @"Chou Runfat", 100);
    
    NSString *sign = [NSString stringWithUTF8String:method_getTypeEncoding(m)];
    NSLog(@"sign: %@", sign);
    
    NSMethodSignature *ms = [obj methodSignatureForSelector:sel];
    NSMethodSignature *otherMs = [DemoObject instanceMethodSignatureForSelector:sel];
    NSLog(@"ms equal: %zd", ms == otherMs);
    NSInvocation *in = [NSInvocation invocationWithMethodSignature:ms];
    [in setSelector:sel];
    NSString *name = @"Chou Taifork";
    NSInteger integer = 200;
    [in setArgument:&name atIndex:2];
    [in setArgument:&integer atIndex:3];
    [in invokeWithTarget:obj];
    
    [obj release];
}

// va_list
static void demo_valist() {
    DemoObject *obj = [DemoObject new];
    char a = 'c';
    int b = 100;
    long c = 200L;
    NSInteger d = 300;
    float e = 400.f;
    CGFloat f = 500.0f;
    BOOL g = true;
    char *h = "123456";
    NSString *i = @"what";
    SEL j = @selector(helloworld:);
    Class k = [DemoObject class];
    struct L {
        int ll;
    };
    struct L l = {600};
    [obj helloworld:0, a, b, c, d, e, f, g, h, i, j, k, l, -1];
    
    [obj release];
}

static void demo_method() {
    NSArray<HGCMethod *> *methods = [DemoObject hgc_methods];
    NSLog(@"methods = %@", methods);
    
    DemoObject *obj = [DemoObject new];
    NSMethodSignature *ms = [obj methodSignatureForSelector:@selector(helloworld:)];
    NSLog(@"arg count = %zd", [ms numberOfArguments]); // 注意可变参数的个数是读不出来的
    
    HGCMethod *m = [DemoObject hgc_methodForSelector:@selector(hello:world:)];
    [m returnValue:nil sendToTarget:obj, HGCARG(@"123"), HGCARG((NSInteger)456)];
    
    m = [DemoObject hgc_methodForSelector:@selector(helloworld:)];
    [m returnValue:nil sendToTarget:obj, HGCARG(@"123"), HGCARG((NSInteger)456), HGCARG((NSInteger)456), HGCARG((NSInteger)456)];
    
    [obj release];
}

// 手工试下方法交换
static void demo_methodSwizzlingInHand() {
    HGCMethod *helloMethod = [DemoObject hgc_methodForSelector:@selector(world:)];
    HGCMethod *worldMethod = [DemoObject hgc_methodForSelector:@selector(dlorw:)];
    IMP helloIMP = [helloMethod implementation];
    [helloMethod setImplementation:[worldMethod implementation]];
    [worldMethod setImplementation:helloIMP];
    
    DemoObject *obj = [DemoObject new];
    [obj world:100];
    [obj dlorw:200];
    [obj release];
}

// 动态增加 method
static bool gAddMethodFlag;
@interface NSObject (AddMethodTest)
- (void)_addMethodTester:(int)i;
@end
static void AddMethodTester(id self, SEL _cmd, int i) {
    NSLog(@"i = %zd", i);
    gAddMethodFlag = YES;
}
static void demo_addMethod() {
    gAddMethodFlag = NO;
    NSLog(@"flag = %zd", gAddMethodFlag);
    id obj = [[NSObject alloc] init];
    HGCMethod *m = [HGCMethod methodWithSelector:@selector(_addMethodTester:) implementation:(IMP)AddMethodTester signature:@"v@:i"];
    [NSObject hgc_addMethod:m];
    [obj _addMethodTester:200];
    NSLog(@"flag = %zd", gAddMethodFlag);
    [obj release];
}

// 测试 Protocol
static void demo_protocol() {
    NSLog(@"All Protocols of Runtime: %@", [HGCProtocol allProtocols]);
    
    HGCProtocol *pt = [HGCProtocol protocolWithObjCProtocol:@protocol(DemoProtocol)];
    NSLog(@"protocol equal: %zd", [pt objCProtocol] == @protocol(DemoProtocol));
    NSLog(@"protocol name: %@", NSStringFromProtocol([pt objCProtocol]));
    
    NSLog(@"Incorporated Protocols: %@", [pt incorporatedProtocols]);

    NSArray *methods;
    methods = [pt methodsRequired:YES instance:YES];
    NSLog(@"req ins m: %@", methods);
    methods = [pt methodsRequired:YES instance:NO];
    NSLog(@"req cls m: %@", methods);
    methods = [pt methodsRequired:NO instance:YES];
    NSLog(@"opt ins m: %@", methods);
    methods = [pt methodsRequired:NO instance:NO];
    NSLog(@"opt cls m: %@", methods);
}

// 测试 ivar
static void demo_ivar() {
    NSArray *ivars = [DemoObject hgc_ivars];
    NSLog(@"ivars: %@", ivars);
    
    HGCIvar *vi = [DemoObject hgc_ivarForName:@"i"];
    NSLog(@"ivar i: name = %@, type encoding = %@, offset = %zd", [vi name], [vi typeEncoding], [vi offset]);
    NSLog(@"offset == sizeof(id): %zd", [vi offset] == sizeof(id));
    
    HGCIvar *vs = [DemoObject hgc_ivarForName:@"s"];
    NSLog(@"ivar s: %@", vs);
    
    HGCIvar *v_s = [DemoObject hgc_ivarForName:@"_s"];
    NSLog(@"ivar _s: name = %@, type encoding = %@, offset = %zd", [v_s name], [v_s typeEncoding], [v_s offset]);
    NSLog(@"_s.offset == i.offset + sizeof(id): %zd", [v_s offset] == [vi offset] + sizeof(id));
    
    HGCIvar *vIsa = [DemoProObject hgc_ivarForName:@"isa"];
    NSLog(@"vIsa = %@", vIsa);
}

// 动态增加 ivar
static void demo_addIvar() {
    HGCUnregisteredClass *cls = [HGCUnregisteredClass unregisteredClassWithName:@"DemoNewObject" withSuperclass:[DemoObject class]];
    HGCIvar *var = [HGCIvar ivarWithName:@"var" encode:@encode(NSNumber *)];
    [cls addIvar:var];
    [cls registerClass];
    
    NSLog(@"ivars: %@", [NSClassFromString(@"DemoNewObject") hgc_ivars]);
    
    // ** DemoNewObject Layout **
    // 0 - isa
    // 8 - i    父类的 ivars
    // 16 - _s  父类的 ivars
    // 24 - var 本类的 ivars
}

// 测试 property
static void demo_property() {
    NSArray *properties = [DemoProObject hgc_properties];
    NSLog(@"properties: %@", properties);
    /*
     (lldb) po attrPairs
     <__NSArrayM 0x100703740>(
     T@"NSString",
     C,
     N,
     GloadName,
     SsaveName:,
     V_name
     )
     
     (lldb) po _attrs
     {
     C = "";
     G = loadName;
     N = "";
     S = "saveName:";
     T = "@\"NSString\"";
     V = "_name";
     }
     
     properties: (
     "<class = _HGCObjCProperty, self = 0x100703240, name = name, attr encodings = saveName:,,loadName,, type encodings = @\"NSString\", ivar name = _name>",
     "<class = _HGCObjCProperty, self = 0x100300730, name = num, attr encodings = ,, type encodings = @\"NSNumber\", ivar name = (null)>",
     "<class = _HGCObjCProperty, self = 0x100300ef0, name = protocl, attr encodings = ,,, type encodings = @\"<DemoProtocol>\", ivar name = (null)>",
     "<class = _HGCObjCProperty, self = 0x100301c20, name = count, attr encodings = , type encodings = q, ivar name = _count>"
     */
    
    // @property (nonatomic, copy, getter=loadName, setter=saveName:) NSString *name;
    HGCProperty *name = [DemoProObject hgc_propertyForName:@"name"];
    NSLog(@"name ** name = %@, attrs = %@, attr encodings = %@, ivar name = %@, type encoding = %@", [name name], [name attributes], [name attributeEncodings], [name ivarName], [name typeEncoding]);
    NSLog(@"name ** setter semantics = %zd, is nonatomic = %zd, setter = %@, getter = %@", [name setterSemantics], [name isNonAtomic], NSStringFromSelector([name customSetter]), NSStringFromSelector([name customGetter]));
    
    // @property (retain) NSNumber *num;
    HGCProperty *num = [DemoProObject hgc_propertyForName:@"num"];
    NSLog(@"num ** name = %@, attrs = %@, attr encodings = %@, ivar name = %@, type encoding = %@", [num name], [num attributes], [num attributeEncodings], [num ivarName], [num typeEncoding]);
    NSLog(@"num ** setter semantics = %zd, is nonatomic = %zd, setter = %@, getter = %@", [num setterSemantics], [num isNonAtomic], NSStringFromSelector([num customSetter]), NSStringFromSelector([num customGetter]));
    NSLog(@"num ** is dynamic = %zd", [num isDynamic]);
    
    // @property (strong) NSMutableString *varname;
    // 和 retain 的属性一样
    HGCProperty *varname = [DemoProObject hgc_propertyForName:@"varname"];
    NSLog(@"varname ** name = %@, attrs = %@, attr encodings = %@, ivar name = %@, type encoding = %@", [varname name], [varname attributes], [varname attributeEncodings], [varname ivarName], [varname typeEncoding]);
    NSLog(@"varname ** setter semantics = %zd, is nonatomic = %zd, setter = %@, getter = %@", [varname setterSemantics], [varname isNonAtomic], NSStringFromSelector([varname customSetter]), NSStringFromSelector([varname customGetter]));
    
    // @property (assign) NSInteger count;
    HGCProperty *count = [DemoProObject hgc_propertyForName:@"count"];
    NSLog(@"count ** name = %@, attrs = %@, attr encodings = %@, ivar name = %@, type encoding = %@", [count name], [count attributes], [count attributeEncodings], [count ivarName], [count typeEncoding]);
    NSLog(@"count ** setter semantics = %zd, is nonatomic = %zd, setter = %@, getter = %@", [count setterSemantics], [count isNonAtomic], NSStringFromSelector([count customSetter]), NSStringFromSelector([count customGetter]));
    
    // @property (nonatomic, readonly, weak) id<DemoProtocol> protocl;
    HGCProperty *protocl = [DemoProObject hgc_propertyForName:@"protocl"];
    NSLog(@"protocl ** name = %@, attrs = %@, attr encodings = %@, ivar name = %@, type encoding = %@", [protocl name], [protocl attributes], [protocl attributeEncodings], [protocl ivarName], [protocl typeEncoding]);
    NSLog(@"protocl ** setter semantics = %zd, is nonatomic = %zd, setter = %@, getter = %@", [protocl setterSemantics], [protocl isNonAtomic], NSStringFromSelector([protocl customSetter]), NSStringFromSelector([protocl customGetter]));
    NSLog(@"protocl ** is readonly = %zd, is dynamic = %zd, is weak = %zd", [protocl isReadOnly], [protocl isDynamic], [protocl isWeakReference]);
}

// 动态增加 property
static void demo_addProperty() {
    HGCUnregisteredClass *ucls = [NSObject hgc_createUnregisteredSubclassNamed:@"AddPropertyClass"];
    HGCIvar *ivar = [HGCIvar ivarWithName:@"assignedIvar" encode:@encode(id)];
    [ucls addIvar:ivar];
    Class cls = [ucls registerClass];
    
    HGCProperty *assignedObjectProp = [HGCProperty propertyWithName:@"assignedObjectProp"
                                                         attributes:@{
                                                                      HGCPropertyTypeEncodingAttribute: [ivar typeEncoding],
                                                                      HGCPropertyBackingIVarNameAttribute: [ivar name],
                                                                      }];
    [cls hgc_addProperty:assignedObjectProp];
    NSLog(@"ivars: %@", [cls hgc_ivars]);
    NSLog(@"properties: %@", [cls hgc_properties]);
}

// instance method swizzling
// class method swizzling
static void demo_ins_cls_methodSwizzling() {
    // instance method swizzling
    NSLog(@"Before instance method swizzling");
    DemoObject *obj = [DemoObject new];
    [obj world:100];
    [obj dlorw:200];
    SEL oldInsSel = @selector(world:);
    SEL newInsSel = @selector(dlorw:);
    HGCMethod *oldInsM = [DemoObject hgc_methodForSelector:oldInsSel];
    HGCMethod *newInsM = [DemoObject hgc_methodForSelector:newInsSel];
    IMP oldInsImp = [oldInsM implementation];
    [oldInsM setImplementation:[newInsM implementation]];
    [newInsM setImplementation:oldInsImp];
    NSLog(@"After instance method swizzling");
    [obj world:100];
    [obj dlorw:200];
    [obj release];
    
    // class method swizzling
    NSLog(@"Before class method swizzling");
    [DemoObject world];
    [DemoObject dlrow];
    SEL oldClsSel = @selector(world);
    SEL newClsSel = @selector(dlrow);
    Class metaCls = [DemoObject hgc_class];
    NSLog(@"is meta: %zd", [metaCls hgc_isMetaClass]);
    HGCMethod *oldClsM = [metaCls hgc_methodForSelector:oldClsSel]; // 元类是 NSObject 的子类，所以能够调用 NSObject 的方法和 category 中的方法
    HGCMethod *newClsM = [metaCls hgc_methodForSelector:newClsSel];
    IMP oldClsImp = [oldClsM implementation];
    [oldClsM setImplementation:[newClsM implementation]];
    [newClsM setImplementation:oldClsImp];
    NSLog(@"After class method swizzling");
    [DemoObject world];
    [DemoObject dlrow];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    return 0;
}
