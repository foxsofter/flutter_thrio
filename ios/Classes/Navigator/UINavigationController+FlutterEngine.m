//
//  UINavigationController+FlutterEngine.m
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import <objc/runtime.h>

#import "UINavigationController+FlutterEngine.h"
#import "NavigatorReceiveChannel.h"
#import "ThrioLogger.h"
#import "ThrioException.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator+NavigatorBuilder.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioFlutterEngine.h"

@interface UINavigationController ()

@property (nonatomic, strong, readonly) NSMutableDictionary *thrio_flutterEngines;

@property (nonatomic, strong) NSDictionary *thrio_flutterEngineUrlCounts;


@end

@implementation UINavigationController (FlutterEngine)

- (NSMutableDictionary * _Nullable)thrio_flutterEngines {
  id flutterEngines = objc_getAssociatedObject(self, _cmd);
  if (!flutterEngines) {
    flutterEngines = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self,
                             _cmd,
                             flutterEngines,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return flutterEngines;
}

- (NSDictionary * _Nullable)thrio_flutterEngineUrlCounts {
  id flutterEngineUrlCounts = objc_getAssociatedObject(self, _cmd);
  if (!flutterEngineUrlCounts) {
    flutterEngineUrlCounts = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self,
                             _cmd,
                             flutterEngineUrlCounts,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return flutterEngineUrlCounts;
}

- (void)setThrio_flutterEngineUrlCounts:(NSDictionary *)flutterEngineUrlCounts {
  objc_setAssociatedObject(self,
                           @selector(thrio_flutterEngineUrlCounts),
                           flutterEngineUrlCounts,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)thrio_startupWithEntrypoint:(NSString *)entrypoint readyBlock:(ThrioVoidCallback)block {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }

  if ([self.thrio_flutterEngines.allKeys containsObject:entrypoint]) {
    block();
  } else {
    ThrioLogV(@"push in thrio_startupWithEntrypoint:%@", entrypoint);
    ThrioFlutterEngine *flutterEngine = [[ThrioFlutterEngine alloc] init];
    [self.thrio_flutterEngines setObject:flutterEngine forKey:entrypoint];
    [flutterEngine startupWithEntrypoint:entrypoint readyBlock:block];
  }
}

- (void)thrio_shutdown {
  [self.thrio_flutterEngines removeAllObjects];
}

- (FlutterEngine *)thrio_getEngineForEntrypoint:(NSString *)entrypoint {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }
  ThrioFlutterEngine *flutterEngine = self.thrio_flutterEngines[entrypoint];
  return flutterEngine.engine;
}

- (ThrioChannel *)thrio_getChannelForEntrypoint:(NSString *)entrypoint {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }
  
  ThrioFlutterEngine *flutterEngine = self.thrio_flutterEngines[entrypoint];
  return flutterEngine.channel;
}

- (void)thrio_attachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"thrio_attachFlutterViewController: %@, %@", viewController.entrypoint, viewController);
  ThrioFlutterEngine *flutterEngine = self.thrio_flutterEngines[viewController.entrypoint];
  [flutterEngine attachFlutterViewController:viewController];
}

- (void)thrio_detachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"thrio_detachFlutterViewController: %@, %@", viewController.entrypoint, viewController);
  ThrioFlutterEngine *flutterEngine = self.thrio_flutterEngines[viewController.entrypoint];
  [flutterEngine detachFlutterViewController:viewController];
}

- (void)thrio_removeAllEngineIfNeeded {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    return;
  }
  // 默认保留一个引擎，正常情况下会是第一个引擎
  if (self.thrio_flutterEngines.count < 2) {
    return;
  }
  
  NSArray *entrypoints = self.thrio_flutterEngines.allKeys;
  
  NSArray *vcs = [self.viewControllers copy];
  for (NSString *entrypoint in entrypoints) {
    NSNumber *urlCount = self.thrio_flutterEngineUrlCounts[entrypoint];
    if (urlCount.integerValue >= ThrioNavigator.multiEngineKeepAliveUrlCount) {
      continue;
    }
    BOOL contains = NO;
    for (UIViewController *vc in vcs) {
      if ([vc isKindOfClass:ThrioFlutterViewController.class] &&
          [[(ThrioFlutterViewController*)vc entrypoint] isEqualToString:entrypoint]) {
        contains = YES;
        break;
      }
    }
    if (!contains) {
      ThrioFlutterEngine *flutterEngine = self.thrio_flutterEngines[entrypoint];
      [flutterEngine shutdown];
      [self.thrio_flutterEngines removeObjectForKey:entrypoint];
    }
  }
}

- (void)thrio_registerUrls:(NSArray *)urls {
  [ThrioNavigator.flutterPageRegisteredUrls addObjectsFromArray:urls];
  
  self.thrio_flutterEngineUrlCounts = [self thrio_groupUrlsByEntrypoint:ThrioNavigator.flutterPageRegisteredUrls];
}

- (void)thrio_unregisterUrls:(NSArray *)urls {
  [ThrioNavigator.flutterPageRegisteredUrls minusSet:[NSSet setWithArray:urls]];
  
  self.thrio_flutterEngineUrlCounts = [self thrio_groupUrlsByEntrypoint:ThrioNavigator.flutterPageRegisteredUrls];
}

#pragma mark - private methods

- (NSDictionary *)thrio_groupUrlsByEntrypoint:(NSSet *)urls {
  NSMutableDictionary *kvs = [NSMutableDictionary dictionary];
  
  for (NSString *url in urls) {
    NSString *entrypoint = [url componentsSeparatedByString:@"/"].firstObject;
    if (![kvs.allKeys containsObject:entrypoint]) {
      kvs[entrypoint] = @1;
    } else {
      NSNumber *v = kvs[entrypoint];
      kvs[entrypoint] = @(v.integerValue + 1);
    }
  }
  
  return kvs;
}



#pragma mark - method swizzling

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self instanceSwizzle:NSSelectorFromString(@"dealloc")
              newSelector:@selector(thrio_dealloc)];
  });
}

- (void)thrio_dealloc {
  [self thrio_shutdown];
  [self thrio_dealloc];
}

@end
