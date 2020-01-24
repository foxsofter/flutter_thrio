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

@implementation UINavigationController (ThrioNavigator)

#pragma mark - navigation methods

- (BOOL)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated {
  @synchronized (self) {
    UIViewController *viewController;
    ThrioNativeViewControllerBuilder builder = [self nativeViewControllerBuilders][url];
    if (builder) {
      viewController = builder(params);
      if (!viewController.hidesNavigationBarWhenPushed) {
        for (UIViewController *vc in self.viewControllers.reverseObjectEnumerator) {
          if (![vc isKindOfClass:ThrioFlutterViewController.class]) {
            viewController.hidesNavigationBarWhenPushed = vc.hidesNavigationBarWhenPushed;
            break;
          }
        }
      }
    } else {
      if ([self.topViewController isKindOfClass:ThrioFlutterViewController.class]) {
        [self.topViewController thrio_pushUrl:url params:params];
        return YES;
      } else {
        ThrioFlutterViewControllerBuilder flutterBuilder = [self flutterViewControllerBuilder];
        if (flutterBuilder) {
         viewController = flutterBuilder();
        } else {
         viewController = [[ThrioFlutterViewController alloc] init];
        }
        viewController.hidesNavigationBarWhenPushed = YES;
      }
    }
    if (viewController) {
      [viewController thrio_pushUrl:url params:params];
      [self pushViewController:viewController animated:animated];
      if ([viewController isKindOfClass:ThrioFlutterViewController.class]) {
        [ThrioApp.shared attachFlutterViewController:(ThrioFlutterViewController*)viewController];
      }
      return YES;
    }
    
    return NO;
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

- (BOOL)thrio_popAnimated:(BOOL)animated {
  UIViewController *vc = self.topViewController;
  if (!vc) {
    return NO;
  }
  if (vc.firstRoute == vc.lastRoute) {
    [self popViewControllerAnimated:animated];
  }
  [vc thrio_pop];
  return YES;
}

- (BOOL)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    return NO;
  }
  [vc thrio_popToUrl:url index:index];
  if (vc != self.topViewController) {
    [self popToViewController:vc animated:animated];
  }
  return YES;
}

- (BOOL)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *)index
               animated:(BOOL)animated {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    return NO;
  }
  if (vc.firstRoute == vc.lastRoute) {
    if (vc == self.topViewController) {
      [self popViewControllerAnimated:animated];
    } else {
      NSMutableArray *vcs = [self.viewControllers mutableCopy];
      [vcs removeObject:vc];
      [self setViewControllers:vcs animated:animated];
    }
  }
  [vc thrio_removeUrl:url index:index];
  return YES;
}

- (NSNumber *)thrio_lastIndex {
  return self.topViewController.lastRoute.settings.index;
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
  if (viewController.hidesNavigationBarWhenPushed != self.topViewController.hidesNavigationBarWhenPushed) {
    [self setNavigationBarHidden:viewController.hidesNavigationBarWhenPushed];
  }

  [self thrio_pushViewController:viewController animated:animated];
}

- (UIViewController * _Nullable)thrio_popViewControllerAnimated:(BOOL)animated {
  UIViewController *willShowVC = self.viewControllers[self.viewControllers.count - 2];
  if ([willShowVC isKindOfClass:ThrioFlutterViewController.class]) {
    [ThrioApp.shared attachFlutterViewController:(ThrioFlutterViewController*)willShowVC];
  }
  if (self.navigationBarHidden != willShowVC.hidesNavigationBarWhenPushed) {
    [self setNavigationBarHidden:willShowVC.hidesNavigationBarWhenPushed];
  }
  return [self thrio_popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> * _Nullable)thrio_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (viewController.hidesNavigationBarWhenPushed != self.topViewController.hidesNavigationBarWhenPushed) {
    [self setNavigationBarHidden:viewController.hidesNavigationBarWhenPushed];
  }
  
  return [self thrio_popToViewController:viewController animated:animated];
}

- (void)thrio_setViewControllers:(NSArray<UIViewController *> *)viewControllers {
  UIViewController *willPopVC = self.topViewController;
  UIViewController *willShowVC = viewControllers.lastObject;
  if (willPopVC.hidesNavigationBarWhenPushed != willShowVC.hidesNavigationBarWhenPushed) {
    [self setNavigationBarHidden:willShowVC.hidesNavigationBarWhenPushed];
  }
  
  [self thrio_setViewControllers:viewControllers];
}

@end

NS_ASSUME_NONNULL_END
