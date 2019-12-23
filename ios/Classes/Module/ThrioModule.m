//
//  ThrioModule.m
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import "ThrioModule.h"

@implementation ThrioModule

static NSMutableDictionary *modules;

+ (void)init {
  NSArray *values = modules.allValues;
  for (ThrioModule *module in values) {
    [module onPageRegister];
  }
  for (ThrioModule *module in values) {
    [module onSyncInit];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    for (ThrioModule *module in values) {
      [module onAsyncInit];
    }
  });
}

+ (void)register:(id<ThrioModuleProtocol>)module {
  if (!modules) {
    modules = [NSMutableDictionary dictionary];
  }
  NSString *key = NSStringFromClass([module class]);
  if (![[modules allKeys] containsObject:key]) {
    [modules setObject:module forKey:key];
    [module onModuleRegister];
  }
}

@end
