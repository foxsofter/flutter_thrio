// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
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

#import "ThrioRegistrySetMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistrySetMap ()

@property (nonatomic, strong) NSMutableDictionary *maps;

@end

@implementation ThrioRegistrySetMap

+ (instancetype)map {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maps = [NSMutableDictionary dictionary];
    }
    return self;
}

- (ThrioVoidCallback)registry:(id<NSCopying>)key value:(id)value {
    NSAssert(key, @"key must not be null.");
    NSAssert(value, @"value must not be null.");

    NSMutableSet *v = [_maps objectForKey:key];
    if (!v) {
        v = [NSMutableSet set];
        [_maps setObject:v forKey:key];
    }

    [v addObject:value];

    __weak typeof(self) weakself = self;
    return ^{
               __strong typeof(weakself) strongSelf = weakself;

               NSMutableSet *v = [strongSelf.maps objectForKey:key];
               [v removeObject:value];
               if (v.count < 1) {
                   [strongSelf.maps removeObjectForKey:key];
               }
    };
}

- (ThrioVoidCallback)registryAll:(NSDictionary *)values {
    NSAssert(values || values.count < 1, @"values must not be null or empty.");
    NSArray *keys = values.allKeys;
    for (id key in keys) {
        NSMutableSet *value = [_maps objectForKey:key];
        if (!value) {
            value = [NSMutableSet set];
            [_maps setObject:value forKey:key];
        }
        [value addObject:[values objectForKey:key]];
    }

    __weak typeof(self) weakself = self;
    return ^{
               __strong typeof(weakself) strongSelf = weakself;

               NSArray *keys = values.allKeys;
               for (id key in keys) {
                   NSMutableSet *value = [strongSelf.maps objectForKey:key];
                   [value removeObject:[values objectForKey:key]];
                   if (value.count < 1) {
                       [strongSelf.maps removeObjectForKey:key];
                   }
               }
    };
}

- (void)clear {
    [_maps removeAllObjects];
}

- (NSSet *)objectForKeyedSubscript:(id<NSCopying>)key {
    return [_maps objectForKey:key];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)enumerationState
                                  objects:(id __unsafe_unretained _Nullable [])buffer
                                    count:(NSUInteger)len {
    return [_maps.allKeys countByEnumeratingWithState:enumerationState
                                              objects:buffer
                                                count:len];
}

- (id)copy {
    ThrioRegistrySetMap *map = [ThrioRegistrySetMap map];
    map.maps = [self.maps mutableCopy];
    return map;
}

@end

NS_ASSUME_NONNULL_END
