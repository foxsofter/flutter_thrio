//
//  ThrioRegistrySet.m
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/10.
//

#import "ThrioRegistrySet.h"

@interface ThrioRegistrySet ()

@property (nonatomic, strong) NSMutableSet *sets;

@end

@implementation ThrioRegistrySet

+ (instancetype)set {
  return [[self alloc] init];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _sets = [NSMutableSet set];
  }
  return self;
}


- (ThrioVoidCallback)registry:(id)value {
  assert(value);
  
  [_sets addObject:value];

  __weak typeof(self) weakself = self;
  return ^{
    __strong typeof(self) strongSelf = weakself;
    
    [strongSelf.sets removeObject:value];
  };
}

- (ThrioVoidCallback)registryAll:(NSSet *)values {
  assert(values || values.count < 1);

  [_sets unionSet:values];
  
  __weak typeof(self) weakself = self;
  return ^{
    __strong typeof(self) strongSelf = weakself;
    [strongSelf.sets minusSet:values];
  };
}

- (void)clear {
  [_sets removeAllObjects];
}

- (NSSet *)values {
  return [_sets copy];
}


@end
