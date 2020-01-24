//
//  ThrioRegistrySetMap.m
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

#import "ThrioRegistrySetMap.h"

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

- (ThrioVoidCallback)registry:(NSString *)key value:(id)value {
  NSAssert(key || key.length < 1, @"key must not be null or empty.");
  NSAssert(value, @"value must not be null.");
  
  NSMutableSet *v = [_maps valueForKey:key];
  if (!v) {
    v = [NSMutableSet set];
    [_maps setValue:v forKey:key];
  }
  
  [v addObject:value];
  
  __weak typeof(self) weakself = self;
  return ^{
    __strong typeof(self) strongSelf = weakself;

    NSMutableSet *v = [strongSelf.maps valueForKey:key];
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
    NSMutableSet *value = [_maps valueForKey:key];
    if (!value) {
      value = [NSMutableSet set];
      [_maps setValue:value forKey:key];
    }
    [value addObject:[values valueForKey:key]];
  }
  
  __weak typeof(self) weakself = self;
  return ^{
    __strong typeof(self) strongSelf = weakself;

    NSArray *keys = values.allKeys;
    for (id key in keys) {
      NSMutableSet *value = [strongSelf.maps valueForKey:key];
      [value removeObject:[values valueForKey:key]];
      if (value.count < 1) {
        [strongSelf.maps removeObjectForKey:key];
      }
    }
  };
}

- (void)clear {
  [_maps removeAllObjects];
}

- (NSSet *)objectForKeyedSubscript:(NSString *)key {
  return [_maps valueForKey:key];
}

@end
