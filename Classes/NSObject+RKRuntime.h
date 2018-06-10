//
//  NSObject+RKRuntime.h
//  RuntimeSample
//
//  Created by 李沛倬 on 2017/9/21.
//  Copyright © 2017年 peizhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (RKRuntime)

#pragma mark - Property

/**
 通过runtime获取当前类所有属性名: 只能获取通过[@property]声明的属性
 
 @return 属性名称数组
 */
- (NSArray<NSString *> *)getPropertyNameList;

/**
 通过runtime获取当前类所有成员变量名: 可以获取到[@property]声明和[@interface大括号中]声明的所有成员变量
 
 @return 成员变量名称数组
 */
- (NSArray<NSString *> *)getIvarNameList;

/**
 通过属性名获取该属性

 @param name 属性名
 @return 属性的Ivar指针
 */
- (Ivar)propertyForName:(NSString *)name;

///**
// 通过属性名获取该属性的值
//
// @param name 属性名
// @return 属性值
// */
//- (id)propertyValueForName:(NSString *)name;
//
///**
// 为一个属性重新赋值
//
// @param name 属性名
// @param newValue 新值
// */
//- (void)reassignWithPropertyName:(NSString *)name newValue:(id)newValue;


/**
 通过属性名获取该属性的类型名
 
 @param name 属性名
 @return 类型名
 */
- (NSString *)typeWithPropertyName:(NSString *)name;

/**
 通过属性名获取该属性所属类
 
 @param name 属性名
 @return 所属类
 */
- (Class)classWithPropertyName:(NSString *)name;



#pragma mark - Method

/**
 通过runtime获取当前类所有方法名
 
 @return 方法名称数组
 */
- (NSArray<NSString *> *)getMethodNameList;

/**
 获取方法对象(Method)

 @param name SEL
 @param cls 方法是在哪个类中实现的（需要据此来确定方法的位置），如果传nil默认在调用该方法的实例所属的类
 @return 方法对象
 */
- (Method)getMethodWithSelector:(SEL)name implementationClass:(Class)cls;

/**
 在运行时为类添加【实例方法】
 
 @param selector SEL
 @param cls 需要添加的方法是在哪个类中实现的（需要据此来确定方法的位置），如果传nil默认在调用该方法的实例所属的类
 @return 是否添加成功
 */
- (BOOL)addInstanceMethodAsRuntime:(SEL)selector implementationClass:(Class)cls;


/**
 在运行时为类添加【类方法】

 @param selector SEL
 @param cls 需要添加的方法是在哪个类中实现的（需要据此来确定方法的位置），如果传nil默认在调用该方法的实例所属的类
 @return 是否添加成功
 */
- (BOOL)addClassMethodAsRuntime:(SEL)selector implementationClass:(Class)cls;


/**
 在运行时为类添加方法（类方法和实例方法均可）

 @param method 可使用 class_getInstanceMethod 或 class_getClassMethod 构造 Method 对象
 @return 是否添加成功
 */
- (BOOL)addMethodAsRuntime:(Method)method;

/**
 方法交换: 交换同类【实例方法】
 
 @param originSEL 需要被交换的原始方法
 @param swizzledSEL 用来交换的方法
 */
- (void)swizzlingInstanceMethodWithOriginMethod:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL;

/**
 方法交换: 交换同类【类方法】
 
 @param originSEL 需要被交换的原始方法
 @param swizzledSEL 用来交换的方法
 */
- (void)swizzlingClassMethodWithOriginMethod:(SEL)originSEL swizzledSEL:(SEL)swizzledSEL;

/**
 交换方法: 相同类或不同类、实例方法或类方法均可

 @param origin 需要被交换的原始方法
 @param swizzle 用来交换的方法
 */
- (void)swizzlingMethodWithOriginMethod:(Method)origin swizzledSEL:(Method)swizzle;


#pragma mark - NSInvocation (不限参数)

/**
 发送消息：【实例方法】调用（包括私有方法）

 @param obj 需要调用方法的类的实例对象
 @param selector 需要调用的【实例方法】
 @param params 参数数组
 @param needReturn 是否需要返回值：如果调用的方法无返回值，而该参数传true则会引起crash
 @return 如果调用的方法有返回值，且needReturn = true，则会返回方法的返回值，否则将返回nil
 */
+ (id)msgSendToObj_invocation:(id)obj selector:(SEL)selector prarms:(NSArray*)params needReturn:(BOOL)needReturn;

- (id)msgSendToObj_invocation:(id)obj selector:(SEL)selector prarms:(NSArray*)params needReturn:(BOOL)needReturn;

/**
 发送消息：【类方法】调用（包括私有方法）
 
 @param cls 需要调用方法的类
 @param selector 需要调用的【类方法】
 @param params 参数数组
 @param needReturn 是否需要返回值：如果调用的方法无返回值，而该参数传true则会引起crash
 @return 如果调用的方法有返回值，且needReturn = true，则会返回方法的返回值，否则将返回nil
 */
+ (id)msgSendToClass_invocation:(Class)cls selector:(SEL)selector prarms:(NSArray*)params needReturn:(BOOL)needReturn;



@end



















