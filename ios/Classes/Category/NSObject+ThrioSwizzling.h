//
//  NSObject+ThrioSwizzling.h
//  thrio
//
//  Created by Wei ZhongDan on 2020/1/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ThrioSwizzling)

// 交换当前类方法的实现
//
// `oldSelector`  原类方法的实现
// `newSelector`  新类方法的实现
//
+ (void)classSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector;

// 交换当前类的实例方法的实现
//
// `oldSelector`  原实例方法的实现
// `newSelector`  新实例方法的实现
//
+ (void)instanceSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector;

@end

NS_ASSUME_NONNULL_END
