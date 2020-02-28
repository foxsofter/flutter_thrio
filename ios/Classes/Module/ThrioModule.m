//
//  ThrioModule.m
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import "ThrioModule.h"
#import "ThrioNavigator+NavigatorBuilder.h"
#import "ThrioNavigator+Internal.h"
#import "UINavigationController+FlutterEngine.h"

@implementation ThrioModule

static NSMutableDictionary *modules;

- (void)registerModule:(id<ThrioModuleProtocol>)module {
  if (!modules) {
    modules = [NSMutableDictionary dictionary];
  }
  NSString *key = NSStringFromClass([module class]);
  if (![[modules allKeys] containsObject:key]) {
    [modules setObject:module forKey:key];
    [module onModuleRegister];
  }
}

- (void)initModule {
  NSArray *values = modules.allValues;
  for (ThrioModule *module in values) {
    if ([module respondsToSelector:@selector(onPageRegister)]) {
      [module onPageRegister];
    }
  }
  for (ThrioModule *module in values) {
    if ([module respondsToSelector:@selector(onModuleInit)]) {
      [module onModuleInit];
    }
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    for (ThrioModule *module in values) {
      if ([module respondsToSelector:@selector(onModuleAsyncInit)]) {
        [module onModuleAsyncInit];
      }
    }
  });
  // 单引擎模式下，提前启动
  if (!ThrioNavigator.isMultiEngineEnabled) {
    [ThrioNavigator.navigationController thrio_startupWithEntrypoint:@"" readyBlock:^{}];
  }
}

- (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                  forUrl:(NSString *)url {
  return [ThrioNavigator registerNativeViewControllerBuilder:builder forUrl:url];
}

- (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder {
  return [ThrioNavigator registerFlutterViewControllerBuilder:builder];
}

- (void)onModuleRegister { }

@end
