// The MIT License (MIT)
//
// Copyright (c) 2021 foxsofter
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.


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
    if ([_params.allKeys containsObject:key]) {
        id oldValue = _params[key];
        if ([oldValue isKindOfClass:NSString.class]) {
            if (![value isKindOfClass:NSString.class]) {
                return;
            }
        } else if ([oldValue isKindOfClass:NSNumber.class]) {
            if (![value isKindOfClass:NSNumber.class]) {
                return;
            }
        } else {
            if (![value isKindOfClass:[oldValue class]]) {
                return;
            }
        }
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
