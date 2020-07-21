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

#import "ThrioRegistryMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistryMap ()

@property (nonatomic, strong) NSMutableDictionary *maps;

@end

@implementation ThrioRegistryMap

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

    [_maps setObject:value forKey:key];

    __weak typeof(self) weakself = self;
    return ^{
               __strong typeof(weakself) strongSelf = weakself;

               [strongSelf.maps removeObjectForKey:key];
    };
}

- (ThrioVoidCallback)registryAll:(NSDictionary *)values {
    NSAssert(values || values.count < 1, @"values must not be null or empty");
    for (id key in values) {
        [_maps setObject:[values objectForKey:key] forKey:key];
    }

    __weak typeof(self) weakself = self;
    return ^{
               __strong typeof(weakself) strongSelf = weakself;

               for (id key in values) {
                   [strongSelf.maps removeObjectForKey:key];
               }
    };
}

- (void)clear {
    [_maps removeAllObjects];
}

- (NSSet *_Nullable)objectForKeyedSubscript:(id)key {
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
    ThrioRegistryMap *map = [ThrioRegistryMap map];
    map.maps = [self.maps mutableCopy];
    return map;
}

@end

NS_ASSUME_NONNULL_END
