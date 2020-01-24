//
//  ThrioRegistryMap.m
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

#import "ThrioRegistryMap.h"

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

- (ThrioVoidCallback)registry:(NSString *)key value:(id)value {
  NSAssert(key || key.length < 1, @"key must not be null or empty.");
  NSAssert(value, @"value must not be null.");
  
  [_maps setValue:value forKey:key];

  __weak typeof(self) weakself = self;
  return ^{
    __strong typeof(self) strongSelf = weakself;
    
    [strongSelf.maps removeObjectForKey:key];
  };
}

- (ThrioVoidCallback)registryAll:(NSDictionary *)values {
  NSAssert(values || values.count < 1, @"values must not be null or empty");
  NSArray *keys = values.allKeys;
  for (id key in keys) {
    [_maps setValue:[values valueForKey:key] forKey:key];
  }
  
  __weak typeof(self) weakself = self;
  return ^{
    __strong typeof(self) strongSelf = weakself;

    NSArray *keys = values.allKeys;
    for (id key in keys) {
      [strongSelf.maps removeObjectForKey:key];
    }
  };
}

- (void)clear {
  [_maps removeAllObjects];
}

- (id)objectForKeyedSubscript:(NSString *)key {
  return [_maps valueForKey:key];
}

@end
