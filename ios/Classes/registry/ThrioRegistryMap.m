//
//  ThrioRegistryMap.m
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

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
    __strong typeof(self) strongSelf = weakself;
    
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
    __strong typeof(self) strongSelf = weakself;

    for (id key in values) {
      [strongSelf.maps removeObjectForKey:key];
    }
  };
}

- (void)clear {
  [_maps removeAllObjects];
}

- (NSSet * _Nullable)objectForKeyedSubscript:(id)key {
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
