//
//  ThrioModuleContext.h
//  thrio
//
//  Created by aadan on 2021/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioModuleContext : NSObject

/// 获取原生端缓存的 kv 值
///
- (id _Nullable)get:(NSString *)key;

/// 获取并删除原生端缓存的 kv 值，如不存在则返回 nil
///
- (id _Nullable)remove:(NSString *)key;

/// 缓存kv值，如可能会将数据同步到所有的 FlutterEngine 的⚓️ Module 上
///
/// 复杂类型需注册序列化器才可以传递到 FlutterEngine 上
///
/// 设置的 `key` 如果已存在， `value` 值的类型须保持一致，否则不会覆盖
///
- (void)set:(id _Nullable)value forKey:(NSString *)key;

/// 获取整型值，不存在则返回 0
///
- (NSInteger)getInteger:(NSString *)key;

/// 获取并删除整型值，不存在则返回 0
///
- (NSInteger)removeInteger:(NSString *)key;

/// 缓存整型值，并将数据同步到所有的 FlutterEngine 的根 Module 上
///
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;

/// 获取布尔值，不存在则返回 NO
///
- (BOOL)getBoolean:(NSString *)key;

/// 获取并删除布尔值，不存在则返回 NO
///
- (BOOL)removeBoolean:(NSString *)key;

/// 缓存布尔值，并将数据同步到所有的 FlutterEngine 的根 Module 上
///
- (void)setBoolean:(BOOL)value forKey:(NSString *)key;

/// 获取并删除double值，不存在则返回 0.0
///
- (double)getDouble:(NSString *)key;

/// 获取并删除double值，不存在则返回 0
///
- (double)removeDouble:(NSString *)key;

/// 缓存double值，并将数据同步到所有的 FlutterEngine 的根 Module 上
///
- (void)setDouble:(double)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
