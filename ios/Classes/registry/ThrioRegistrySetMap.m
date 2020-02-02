//
//  ThrioRegistrySetMap.m
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

#import "ThrioRegistrySetMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistrySetMap()

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
    __strong typeof(self) strongSelf = weakself;

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
    __strong typeof(self) strongSelf = weakself;

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
                                    count:(NSUInteger) len {
    return [_maps.allKeys countByEnumeratingWithState:enumerationState
                                              objects:buffer
                                                count:len];
}

@end

NS_ASSUME_NONNULL_END
