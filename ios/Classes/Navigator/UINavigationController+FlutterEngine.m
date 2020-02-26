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
#import "NSObject+ThrioSwizzling.h"
#import "ThrioFlutterEngine.h"

@interface UINavigationController ()

@property (nonatomic, strong, readonly) NSMutableDictionary *thrio_flutterEngines;

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

- (void)thrio_startupWithEntrypoint:(NSString *)entrypoint readyBlock:(ThrioVoidCallback)block {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }

  if ([self.thrio_flutterEngines.allKeys containsObject:entrypoint]) {
    block();
  } else {
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

- (void)thrio_removeIfNeeded {
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
