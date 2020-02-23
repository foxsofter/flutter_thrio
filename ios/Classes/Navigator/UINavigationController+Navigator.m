//
//  UINavigationController+ThrioNavigator.m
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <objc/runtime.h>
#import "UINavigationController+Navigator.h"
#import "UINavigationController+FlutterEngine.h"
#import "UINavigationController+PopGesture.h"
#import "UIViewController+Navigator.h"
#import "NavigatorNotifyProtocol.h"
#import "ThrioRegistryMap.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioLogger.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+NavigatorBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController ()

// 记下当前正要被pop的`UIViewController`
@property (nonatomic, strong, nullable) UIViewController *thrio_popingViewController;

// 记下第一个ThrioFlutterViewController
@property (nonatomic, strong, nullable) UIViewController *thrio_firstFlutterViewController;

@end

@implementation UINavigationController (Navigator)

- (UIViewController * _Nullable)thrio_popingViewController {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_popingViewController:(UIViewController * _Nullable)viewController {
  objc_setAssociatedObject(self,
                           @selector(thrio_popingViewController),
                           viewController,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioFlutterViewController * _Nullable)thrio_firstFlutterViewController {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_firstFlutterViewController:(ThrioFlutterViewController * _Nullable)viewController {
  objc_setAssociatedObject(self,
                           @selector(thrio_firstFlutterViewController),
                           viewController,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - navigation methods

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated
               result:(ThrioBoolCallback)result{
  @synchronized (self) {
    UIViewController *viewController;
    ThrioNativeViewControllerBuilder builder = [ThrioNavigator nativeViewControllerBuilders][url];
    if (builder) {
      viewController = builder(params);
      if (viewController.thrio_hidesNavigationBar == nil) {
        // 寻找不是FlutterViewController的UIViewController，获取其thrio_hidesNavigationBar
        for (UIViewController *vc in self.viewControllers.reverseObjectEnumerator) {
          if (![vc isKindOfClass:ThrioFlutterViewController.class]) {
            viewController.thrio_hidesNavigationBar = vc.thrio_hidesNavigationBar;
            break;
          }
        }
      }
    } else {
      [self thrio_startup];

      if ([self.topViewController isKindOfClass:ThrioFlutterViewController.class]) {
        NSNumber *index = @([self thrio_getLastIndexByUrl:url].integerValue + 1);
        [self.topViewController thrio_pushUrl:url
                                        index:index
                                       params:params
                                     animated:animated
                                       result:^(BOOL r) {
          if (r) {
            [self thrio_removePopGesture];
          }
          result(r);
        }];
        return;
      }
      
      ThrioFlutterViewControllerBuilder flutterBuilder = [ThrioNavigator flutterViewControllerBuilder];
      if (flutterBuilder) {
       viewController = flutterBuilder();
      } else {
       viewController = [[ThrioFlutterViewController alloc] init];
      }
      viewController.thrio_hidesNavigationBar = @YES;
    }
    if (viewController) {
      NSNumber *index = @([self thrio_getLastIndexByUrl:url].integerValue + 1);
      __weak typeof(self) weakself = self;
      [viewController thrio_pushUrl:url index:index params:params animated:animated result:^(BOOL r) {
        if (r) {
          __strong typeof(self) strongSelf = weakself;
          [strongSelf pushViewController:viewController animated:animated];
          if ([viewController isKindOfClass:ThrioFlutterViewController.class]) {
            [self thrio_attachFlutterViewController:(ThrioFlutterViewController*)viewController];
          }
        }
        result(r);
      }];
    }
  }
}

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber *)index
                   name:(NSString *)name
                 params:(NSDictionary *)params {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if ([vc conformsToProtocol:@protocol(NavigatorNotifyProtocol)]) {
    return [vc thrio_notifyUrl:url index:index name:name params:params];
  }
  return NO;
}

- (void)thrio_popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
  UIViewController *vc = self.topViewController;
  if (!vc) {
    result(NO);
    return;
  }
  __weak typeof(self) weakself = self;
  [vc thrio_popAnimated:animated result:^(BOOL r) {
    __strong typeof(self) strongSelf = weakself;
    if (r && !vc.thrio_firstRoute) {
      [strongSelf popViewControllerAnimated:animated];
    }
    if (r && vc.thrio_firstRoute == vc.thrio_lastRoute) {
      [strongSelf thrio_addPopGesture];
    }
    result(r);
  }];
}

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback)result {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    result(NO);
    return;
  }
  __weak typeof(self) weakself = self;
  [vc thrio_popToUrl:url index:index animated:animated result:^(BOOL r) {
    __strong typeof(self) strongSelf = weakself;
    if (r && vc != self.topViewController) {
      [strongSelf popToViewController:vc animated:animated];
    }
    if (r && vc.thrio_firstRoute == vc.thrio_lastRoute) {
      [strongSelf thrio_addPopGesture];
    }
    result(r);
  }];
}

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback)result {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    result(NO);
    return;
  }
  __weak typeof(self) weakself = self;
  [vc thrio_removeUrl:url index:index animated:animated result:^(BOOL r) {
    __strong typeof(self) strongSelf = weakself;
    if (r && !vc.thrio_firstRoute) {
      if (vc == strongSelf.topViewController) {
        [strongSelf popViewControllerAnimated:animated];
      } else {
        NSMutableArray *vcs = [strongSelf.viewControllers mutableCopy];
        [vcs removeObject:vc];
        [strongSelf setViewControllers:vcs animated:animated];
      }
    }
    if (r && vc.thrio_firstRoute == vc.thrio_lastRoute) {
      [strongSelf thrio_addPopGesture];
    }
    result(r);
  }];
}

- (void)thrio_didPushUrl:(NSString *)url index:(NSNumber *)index {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    return;
  }
  
  [vc thrio_didPushUrl:url index:index];
  if (vc.thrio_firstRoute == vc.thrio_lastRoute) {
    [self thrio_addPopGesture];
  } else {
    [self thrio_removePopGesture];
  }
}

- (void)thrio_didPopUrl:(NSString *)url index:(NSNumber *)index {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (vc) {
    [vc thrio_didPopUrl:url index:index];
    if (vc.thrio_firstRoute == vc.thrio_lastRoute) {
      [self thrio_addPopGesture];
    }
  }
}

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    return;
  }
  
  [vc thrio_didPopToUrl:url index:index];
  if (vc.thrio_firstRoute == vc.thrio_lastRoute) {
    [self thrio_addPopGesture];
  }
}

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    return;
  }
  
  [vc thrio_didRemoveUrl:url index:index];
  if (vc.thrio_firstRoute == vc.thrio_lastRoute) {
    [self thrio_addPopGesture];
  }
}

- (NSNumber *)thrio_lastIndex {
  return self.topViewController.thrio_lastRoute.settings.index;
}

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url {
  UIViewController *vc = [self getViewControllerByUrl:url index:@0];
  return [vc thrio_getLastIndexByUrl:url];
}

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url {
  NSArray *vcs = self.viewControllers;
  NSMutableArray *indexs = [NSMutableArray array];
  for (UIViewController *vc in vcs) {
    [indexs addObjectsFromArray:[vc thrio_getAllIndexByUrl:url]];
  }
  return indexs;
}

- (BOOL)thrio_ContainsUrl:(NSString *)url {
  return [self getViewControllerByUrl:url index:@0] != nil;
}

- (BOOL)thrio_ContainsUrl:(NSString *)url index:(NSNumber *)index {
  return [self getViewControllerByUrl:url index:index] != nil;
}

- (UIViewController * _Nullable)getViewControllerByUrl:(NSString *)url
                                                 index:(NSNumber *)index {
  if (url.length < 1) {
    return self.topViewController;
  }
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  for (UIViewController *vc in vcs) {
    if ([vc thrio_getRouteByUrl:url index:index]) {
      return vc;
    }
  }
  return nil;
}

#pragma mark - method swizzling

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self instanceSwizzle:@selector(pushViewController:animated:)
              newSelector:@selector(thrio_pushViewController:animated:)];
    [self instanceSwizzle:@selector(popViewControllerAnimated:)
              newSelector:@selector(thrio_popViewControllerAnimated:)];
    [self instanceSwizzle:@selector(popToViewController:animated:)
              newSelector:@selector(thrio_popToViewController:animated:)];
    [self instanceSwizzle:@selector(setViewControllers:)
              newSelector:@selector(thrio_setViewControllers:)];
  });
}

- (void)thrio_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (![viewController.thrio_hidesNavigationBar isEqualToNumber:self.topViewController.thrio_hidesNavigationBar]) {
    [self setNavigationBarHidden:viewController.thrio_hidesNavigationBar.boolValue];
  }
  
  [self thrio_pushViewController:viewController animated:animated];
}

- (UIViewController * _Nullable)thrio_popViewControllerAnimated:(BOOL)animated {
  if (self.topViewController.thrio_lastRoute.popDisabled) {
    return nil;
  }
  
  self.thrio_popingViewController = self.topViewController;
  
  return [self thrio_popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> * _Nullable)thrio_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (![viewController.thrio_hidesNavigationBar isEqualToNumber:self.topViewController.thrio_hidesNavigationBar]) {
    [self setNavigationBarHidden:viewController.thrio_hidesNavigationBar.boolValue];
  }
    
  return [self thrio_popToViewController:viewController animated:animated];
}

- (void)thrio_setViewControllers:(NSArray<UIViewController *> *)viewControllers {
  UIViewController *willPopVC = self.topViewController;
  UIViewController *willShowVC = viewControllers.lastObject;
  if (![willPopVC.thrio_hidesNavigationBar isEqualToNumber:willShowVC.thrio_hidesNavigationBar]) {
    [self setNavigationBarHidden:willShowVC.thrio_hidesNavigationBar.boolValue];
  }
  
  [self thrio_setViewControllers:viewControllers];
}

- (void)thrio_didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (![self.thrio_popingViewController isKindOfClass:ThrioFlutterViewController.class]) {
    return;
  }
  
  // 处理didPop的情况
  __weak typeof(self) weakself = self;
  [self.thrio_popingViewController thrio_popAnimated:animated result:^(BOOL r) {
    if (r) {
      __strong typeof(self) strongSelf = weakself;
      if ([viewController isKindOfClass:ThrioFlutterViewController.class]) {
        [self thrio_attachFlutterViewController:(ThrioFlutterViewController*)viewController];
      }
      if (strongSelf.navigationBarHidden != viewController.thrio_hidesNavigationBar.boolValue) {
        [strongSelf setNavigationBarHidden:viewController.thrio_hidesNavigationBar.boolValue];
      }
    }
    self.thrio_popingViewController = nil;
  }];
}

@end

NS_ASSUME_NONNULL_END
