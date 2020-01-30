//
//  UINavigationController+ThrioNavigator.m
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <objc/runtime.h>
#import "UINavigationController+ThrioNavigator.h"
#import "UIViewController+ThrioPageRoute.h"
#import "ThrioNotifyProtocol.h"
#import "ThrioRegistryMap.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioApp.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController ()

@property (nonatomic, strong, readonly) ThrioNavigationControllerDelegate *thrio_navigationControllerDelegate;

@end

@implementation UINavigationController (ThrioNavigator)

- (ThrioNavigationControllerDelegate *)thrio_navigationControllerDelegate {
  ThrioNavigationControllerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
  if (!delegate) {
    delegate = [[ThrioNavigationControllerDelegate alloc] init];
    delegate.navigationController = self;
    objc_setAssociatedObject(self,
                             _cmd,
                             delegate,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return delegate;
}

- (ThrioPopGestureRecognizerDelegate *)thrio_popGestureRecognizerDelegate {
  ThrioPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
  if (!delegate) {
    delegate = [[ThrioPopGestureRecognizerDelegate alloc] init];
    delegate.navigationController = self;
    objc_setAssociatedObject(self,
                             _cmd,
                             delegate,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return delegate;
}

- (UIPanGestureRecognizer *)thrio_popGestureRecognizer {
  UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
  if (!panGestureRecognizer) {
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    panGestureRecognizer.maximumNumberOfTouches = 1;

    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
    panGestureRecognizer.delegate = self.thrio_popGestureRecognizerDelegate;
    [panGestureRecognizer addTarget:internalTarget action:internalAction];
    self.interactivePopGestureRecognizer.enabled = NO;

    objc_setAssociatedObject(self,
                             _cmd,
                             panGestureRecognizer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return panGestureRecognizer;
}

#pragma mark - navigation methods

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated
               result:(ThrioBoolCallback)result{
  @synchronized (self) {
    UIViewController *viewController;
    ThrioNativeViewControllerBuilder builder = [self nativeViewControllerBuilders][url];
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
      if ([self.topViewController isKindOfClass:ThrioFlutterViewController.class]) {
        [self.topViewController thrio_pushUrl:url params:params animated:animated result:^(BOOL r) {
          if (r) {
            [self thrio_removePopGesture];
          }
          result(r);
        }];
        return;
      } else {
        ThrioFlutterViewControllerBuilder flutterBuilder = [self flutterViewControllerBuilder];
        if (flutterBuilder) {
         viewController = flutterBuilder();
        } else {
         viewController = [[ThrioFlutterViewController alloc] init];
        }
        viewController.thrio_hidesNavigationBar = @YES;
      }
    }
    if (viewController) {
      __weak typeof(self) weakself = self;
      [viewController thrio_pushUrl:url params:params animated:animated result:^(BOOL r) {
        if (r) {
          __strong typeof(self) strongSelf = weakself;
          [strongSelf pushViewController:viewController animated:animated];
          if ([viewController isKindOfClass:ThrioFlutterViewController.class]) {
            [ThrioApp.shared attachFlutterViewController:(ThrioFlutterViewController*)viewController];
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
  if ([vc conformsToProtocol:@protocol(ThrioNotifyProtocol)]) {
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

- (ThrioVoidCallback)thrio_registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                        forUrl:(NSString *)url {
  ThrioRegistryMap *builders = [self nativeViewControllerBuilders];
  if (!builders) {
    builders = [ThrioRegistryMap map];
    [self setNativeViewControllerBuilders:builders];
  }
  return [builders registry:url value:builder];
}

- (ThrioVoidCallback)thrio_registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder {
  [self setFlutterViewControllerBuilder:builder];
  return ^ {
    [self setFlutterViewControllerBuilder:nil];
  };
}

- (ThrioFlutterViewControllerBuilder _Nullable)flutterViewControllerBuilder {
  return objc_getAssociatedObject(self, @selector(setFlutterViewControllerBuilder:));
}

- (void)setFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder _Nullable)builder {
  objc_setAssociatedObject(self,
                           @selector(setFlutterViewControllerBuilder:),
                           builder,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - private methods

- (UIViewController * _Nullable)getViewControllerByUrl:(NSString *)url
                                                 index:(NSNumber *)index {
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  for (UIViewController *vc in vcs) {
    if ([vc thrio_getRouteByUrl:url index:index]) {
      return vc;
    }
  }
  return nil;
}

- (ThrioRegistryMap *)nativeViewControllerBuilders {
  return objc_getAssociatedObject(self, @selector(setNativeViewControllerBuilders:));
}

- (void)setNativeViewControllerBuilders:(ThrioRegistryMap *)builders {
  objc_setAssociatedObject(self,
                           @selector(setNativeViewControllerBuilders:),
                           builders,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
  __weak typeof(self) weakself = self;
  [self.topViewController thrio_popAnimated:animated result:^(BOOL r) {
    if (r) {
      __strong typeof(self) strongSelf = weakself;
      UIViewController *willShowVC = strongSelf.viewControllers[strongSelf.viewControllers.count - 2];
      if ([willShowVC isKindOfClass:ThrioFlutterViewController.class]) {
        [ThrioApp.shared attachFlutterViewController:(ThrioFlutterViewController*)willShowVC];
      }
      if ([strongSelf.topViewController isKindOfClass:ThrioFlutterViewController.class]) {
        BOOL containsFlutterViewController = NO;
        for (UIViewController *vc in strongSelf.viewControllers.reverseObjectEnumerator) {
          if ([vc isKindOfClass:ThrioFlutterViewController.class]) {
            containsFlutterViewController = YES;
            break;
          }
        }
        if (!containsFlutterViewController) {
          [ThrioApp.shared detachFlutterViewController];
        }
        [self thrio_removePopGesture];
      }
      if (strongSelf.navigationBarHidden != willShowVC.thrio_hidesNavigationBar.boolValue) {
        [strongSelf setNavigationBarHidden:willShowVC.thrio_hidesNavigationBar.boolValue];
      }
    }
  }];

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

#pragma mark - private methods

- (void)thrio_addPopGesture {
  if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.thrio_popGestureRecognizer]) {
    [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.thrio_popGestureRecognizer];
  }
  
  self.delegate = self.thrio_navigationControllerDelegate;
}

- (void)thrio_removePopGesture {
  if ([self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.thrio_popGestureRecognizer]) {
    [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.thrio_popGestureRecognizer];
  }
  self.delegate = self.thrio_navigationControllerDelegate.originDelegate;
}

@end

NS_ASSUME_NONNULL_END
