//
//  NSObject+RKRuntime.m
//  RuntimeSample
//
//  Created by 李沛倬 on 2017/9/21.
//  Copyright © 2017年 peizhuo. All rights reserved.
//

#import "NSObject+RKRuntime.h"
#import <objc/message.h>

@implementation NSObject (RKRuntime)

#pragma mark - Property

/**
 通过runtime获取当前类所有属性名

 @return 属性名称数组
 */
- (NSArray<NSString *> *)getPropertyNameList {
    
    u_int outCount = 0;
    
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    
    NSMutableArray<NSString *> *propertyList = [NSMutableArray arrayWithCapacity:outCount];
    
    for (NSInteger i = 0; i < outCount; i++) {
        
        const char *propertyName = property_getName(properties[i]);
        
        NSString *name = [[NSString alloc] initWithUTF8String:propertyName];
        
        [propertyList addObject:name];
    }
    
    return propertyList;
}


/**
 通过runtime获取当前类所有成员变量名

 @return 成员变量名称数组
 */
- (NSArray<NSString *> *)getIvarNameList {
    
    u_int outCount = 0;
    
    Ivar *ivars = class_copyIvarList(self.class, &outCount);
    
    NSMutableArray<NSString *> *ivarList = [NSMutableArray arrayWithCapacity:outCount];
    
    for (NSInteger i = 0; i < outCount; i++) {
        
        const char *propertyName = ivar_getName(ivars[i]);
        
        NSString *name = [[NSString alloc] initWithUTF8String:propertyName];
        
        [ivarList addObject:name];
    }
    
    return ivarList;
}


/**
 通过属性名获取该属性

 @param name 属性名
 @return 属性的Ivar指针
 */
- (Ivar)propertyForName:(NSString *)name {
    
    return class_getInstanceVariable(self.class, [name UTF8String]);
}


/**
 通过属性名获取该属性的值

 @param name 属性名
 @return 属性值
 */
- (id)propertyValueForName:(NSString *)name {
    
    return object_getIvar(name, [self propertyForName:name]);
}


/**
 为一个属性重新赋值

 @param name 属性名
 @param newValue 新值
 */
- (void)reassignWithPropertyName:(NSString *)name newValue:(id)newValue {
    
//    objc_property_t property = class_getProperty(self.class, [name UTF8String]);
    
    object_setIvar(self, [self propertyForName:name], newValue);
}


/**
 通过属性名获取该属性的类型名

 @param name 属性名
 @return 类型名
 */
- (NSString *)typeWithPropertyName:(NSString *)name {
    
    Ivar ivar = [self propertyForName:name];
    
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    
    return [NSString stringWithUTF8String:typeEncoding];
}


/**
 通过属性名获取该属性所属类

 @param name 属性名
 @return 所属类
 */
- (Class)classWithPropertyName:(NSString *)name {
    
    NSString *type = [self typeWithPropertyName:name];
    
    return NSClassFromString(type);
}

#pragma mark - Method

/**
 通过runtime获取当前类所有方法名
 
 @return 方法名称数组
 */
- (NSArray<NSString *> *)getMethodNameList {
    
    u_int outCount = 0;
    
    Method *methods = class_copyMethodList(self.class, &outCount);
    
    NSMutableArray<NSString *> *methodList = [NSMutableArray arrayWithCapacity:outCount];
    
    for (int i = 0; i < outCount ; i++) {
        SEL name = method_getName(methods[i]);
        
        const char *charName = sel_getName(name);
        
        NSString *methodName = [NSString stringWithCString:charName encoding:NSUTF8StringEncoding];
        
        [methodList addObject:methodName];
    }
    
    return methodList;
}

/**
 获取方法对象(Method)
 
 @param name SEL
 @param cls 方法是在哪个类中实现的（需要据此来确定方法的位置），如果传nil默认在调用该方法的实例所属的类
 @return 方法对象
 */
- (Method)getMethodWithSelector:(SEL)name implementationClass:(Class)cls {

    Method method = class_getInstanceMethod(cls ? : self.class, name);
    
    return method;
}


/**
 在运行时为类添加实例方法

 @param selector SEL
 @return 是否添加成功
 */
- (BOOL)addInstanceMethodAsRuntime:(SEL)selector implementationClass:(Class)cls {
    
    Method method = class_getInstanceMethod(cls ? : self.class, selector);
    
    return [self addMethodAsRuntime:method];
}

/**
 在运行时为类添加类方法
 
 @param selector SEL
 @return 是否添加成功
 */
- (BOOL)addClassMethodAsRuntime:(SEL)selector implementationClass:(Class)cls {
    
    Method method = class_getClassMethod(cls ? : self.class, selector);
    
    return [self addMethodAsRuntime:method];
}


- (BOOL)addMethodAsRuntime:(Method)method {
    
    IMP imp = method_getImplementation(method);
    
    const char *type = method_getTypeEncoding(method);
    
    BOOL isAdded = class_addMethod(self.class, method_getName(method), imp, type);
    
    return isAdded && [self respondsToSelector:method_getName(method)];
}


/**
 方法交换: 交换实例方法

 @param originSEL 需要被交换的原始方法
 @param swizzledSEL 用来交换的方法
 */
- (void)swizzlingInstanceMethodWithOriginMethod:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL {
    
    Method origin = class_getInstanceMethod(self.class, originSEL);
    
    Method swizzle = class_getInstanceMethod(self.class, swizzledSEL);
    
    [self swizzlingMethodWithOriginMethod:origin swizzledSEL:swizzle];
    
}

/**
 方法交换: 交换类方法
 
 @param originSEL 需要被交换的原始方法
 @param swizzledSEL 用来交换的方法
 */
- (void)swizzlingClassMethodWithOriginMethod:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL {
    
    Method origin = class_getClassMethod(self.class, originSEL);
    
    Method swizzle = class_getClassMethod(self.class, swizzledSEL);
    
    [self swizzlingMethodWithOriginMethod:origin swizzledSEL:swizzle];
    
}

- (void)swizzlingMethodWithOriginMethod:(Method)origin swizzledSEL:(Method)swizzle {
    
    BOOL addSuccess = [self addMethodAsRuntime:origin];
    
    if (addSuccess) {
        class_addMethod(self.class, method_getName(swizzle), method_getImplementation(origin), method_getTypeEncoding(origin));
    }else {
        method_exchangeImplementations(origin, swizzle);
    }
    
}



#pragma mark - NSInvocation (不限参数)

- (id)msgSendToObj_invocation:(id)obj selector:(SEL)selector prarms:(NSArray*)params needReturn:(BOOL)needReturn {
    
    id value = nil;
    
    if (obj && selector) {
        
        if ([obj respondsToSelector:selector]) {
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[obj class] instanceMethodSignatureForSelector:selector]];
            
            [invocation setSelector:selector];
            
            [invocation setTarget:obj];
            
            for (int i = 0; i < params.count; i++) {
                id ref = params[i];
                
                [invocation setArgument:&ref atIndex:2+i];
            }
            
            [invocation invoke];//perform 的传参表达方式
            
            if (needReturn) {//获得返回值
                void *vvl = nil;
                
                [invocation getReturnValue:&vvl];
                
                value = (__bridge id)vvl;
            }
            
        }else {
            
            NSLog(@"msgToTarget unRespondsToSelector -->>> %@ %@", obj, NSStringFromSelector(selector));
        }
    }
    
    return value;
    
}

+ (id)msgSendToObj_invocation:(id)obj selector:(SEL)selector prarms:(NSArray*)params needReturn:(BOOL)needReturn {
    
    return [[self new] msgSendToObj_invocation:obj selector:selector prarms:params needReturn:needReturn];
}

+ (id)msgSendToClass_invocation:(Class)cls selector:(SEL)selector prarms:(NSArray*)params needReturn:(BOOL)needReturn {
    id value = nil;
    
    Method method = class_getClassMethod(cls, selector);
    
    if ((int)method != 0) {
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[cls methodSignatureForSelector:selector]];
        
        [invocation setSelector:selector];
        
        [invocation setTarget:cls];
        
        for (int i = 0; i < params.count; i++) {
            id ref = params[i];
            
            [invocation setArgument:&ref atIndex:2+i];
        }
        
        [invocation invoke];//perform 的传参表达方式
        
        if (needReturn) {//获得返回值
            void *vvl = nil;
            
            [invocation getReturnValue:&vvl];
            
            value = (__bridge id)vvl;
        }
        
    }else {
        
        NSLog(@"msgToTarget unRespondsToSelector -->>> %@ %@", cls, NSStringFromSelector(selector));
    }
    
    return value;
}


@end

























