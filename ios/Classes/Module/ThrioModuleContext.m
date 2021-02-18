//
//  ThrioModuleContext.m
//  thrio
//
//  Created by aadan on 2021/1/31.
//

#import "ThrioModuleContext.h"
#import "ThrioModuleContext+Internal.h"
#import "ThrioModule+JsonSerializers.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NSObject+Thrio.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioModuleContext

- (instancetype)init {
    if (self = [super init]) {
        _params = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id _Nullable)get:(NSString *)key {
    return _params[key];
}

- (void)set:(id _Nullable)value forKey:(NSString *)key {
    if ([_params.allKeys containsObject:key] &&
        ![NSStringFromClass([_params[key] class]) isEqualToString:NSStringFromClass([value class])]) {
        return;
    }
    id v = _params[key];
    if (v != value) {
        _params[key] = value;
        id v = [ThrioModule serializeParams:value];
        if ([v canTransToFlutter]) {
            // 将数据同步给所有的 FlutterEngine
            [NavigatorFlutterEngineFactory.shared setModuleContextValue:value
                                                                 forKey:key];
        }
    }
}

- (id _Nullable)remove:(NSString *)key {
    id value = _params[key];
    if (value) {
        [_params removeObjectForKey:key];
        // 将数据同步给所有的 FlutterEngine
        [NavigatorFlutterEngineFactory.shared setModuleContextValue:nil
                                                             forKey:key];
    }

    return value;
}

- (NSInteger)getInteger:(NSString *)key {
    NSNumber *value = [self get:key];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.integerValue;
    }
    return 0;
}

- (NSInteger)removeInteger:(NSString *)key {
    NSNumber *value = [self remove:key];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.integerValue;
    }
    return 0;
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [self set:[NSNumber numberWithInteger:value] forKey:key];
}

- (BOOL)getBoolean:(NSString *)key {
    NSNumber *value = [self get:key];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.boolValue;
    }
    return NO;
}

- (BOOL)removeBoolean:(NSString *)key {
    NSNumber *value = [self remove:key];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.boolValue;
    }
    return NO;
}

- (void)setBoolean:(BOOL)value forKey:(NSString *)key {
    [self set:[NSNumber numberWithBool:value] forKey:key];
}

- (double)getDouble:(NSString *)key {
    NSNumber *value = [self get:key];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.doubleValue;
    }
    return 0.0;
}

- (double)removeDouble:(NSString *)key {
    NSNumber *value = [self remove:key];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.doubleValue;
    }
    return 0.0;
}

- (void)setDouble:(double)value forKey:(NSString *)key {
    [self set:[NSNumber numberWithDouble:value] forKey:key];
}

@end

NS_ASSUME_NONNULL_END
