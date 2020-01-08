//
//  UINavigationController+Thrio.m
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <objc/runtime.h>
#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioPage.h"
#import "ThrioNotifyProtocol.h"
#import "ThrioRegistryMap.h"
#import "ThrioFlutterPage.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioApp.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UINavigationController (ThrioRouter)

#pragma mark - ThrioNavigationProtocol methods

- (BOOL)pushPageWithUrl:(NSString *)url
                 params:(NSDictionary *)params
               animated:(BOOL)animated {
  UIViewController *page;
  ThrioNativePageBuilder builder = [self nativePageBuilders][url];
  if (builder) {
    page = builder(params);
  } else if ([self flutterPageBuilder]) {
    page = [self flutterPageBuilder]();
    page.hidesNavigationBarWhenPushed = YES;
  } else {
    page = [[ThrioFlutterPage alloc] init];
    page.hidesNavigationBarWhenPushed = YES;
  }
  page.pageParams = page.pageParams ?: params;
  page.pageUrl = url;
  [self pushViewController:page animated:animated];
  return YES;
}

- (BOOL)notifyPageWithName:(NSString *)name
                       url:(NSString *)url
                     index:(NSNumber *)index
                    params:(NSDictionary *)params {
  UIViewController *vc = [self getPageWithUrl:url index:index];
  if ([vc conformsToProtocol:@protocol(ThrioNotifyProtocol)]) {
    if (!(vc.pageNotifications)) {
      vc.pageNotifications = [NSMutableDictionary dictionary];
    }
    [vc.pageNotifications setValue:params ? params : @{} forKey:name];
    return YES;
  }
  return NO;
}

- (BOOL)popPageWithUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated {
  if (url.length < 1) {
    [self popViewControllerAnimated:animated];
    return YES;
  }
  UIViewController *vc = [self getPageWithUrl:url index:index];
  if (!vc) {
    return NO;
  }
  if (vc == self.topViewController) {
    [self popViewControllerAnimated:animated];
  } else {
    [[ThrioApp.shared channel] invokeMethod:@"__onPop__" arguments:[vc pageArguments]];
    
    NSMutableArray *vcs = [self.viewControllers mutableCopy];
    [vcs removeObject:vc];
    [self setViewControllers:vcs animated:animated];
  }
  return YES;
}

- (BOOL)popToPageWithUrl:(NSString *)url
                   index:(NSNumber *)index
                animated:(BOOL)animated {
  UIViewController *vc = [self getPageWithUrl:url index:index];
  if (!vc || vc == self.topViewController) {
    return NO;
  }
  [self popToViewController:vc animated:animated];
  return YES;
}

- (NSNumber *)topmostPageIndexWithUrl:(NSString *)url {
  UIViewController *vc = [self getPageWithUrl:url index:@0];
  return vc.pageIndex;
}

- (NSArray *)allPageIndexWithUrl:(NSString *)url {
  NSArray *vcs = self.viewControllers;
  NSMutableArray *indexs = [NSMutableArray array];
  for (UIViewController *vc in vcs) {
    if ([vc.pageUrl isEqualToString:url]) {
      [indexs addObject:vc.pageIndex];
    }
  }
  return indexs;
}

- (BOOL)containsPageWithUrl:(NSString *)url {
  return [self getPageWithUrl:url index:@0] != nil;
}

- (BOOL)containsPageWithUrl:(NSString *)url index:(NSNumber *)index {
  return [self getPageWithUrl:url index:index] != nil;
}

- (ThrioVoidCallback)registerNativePageBuilder:(ThrioNativePageBuilder)builder
                                        forUrl:(NSString *)url {
  ThrioRegistryMap *pageBuilders = [self nativePageBuilders];
  if (!pageBuilders) {
    pageBuilders = [ThrioRegistryMap map];
    [self setNativePageBuilders:pageBuilders];
  }
  return [pageBuilders registry:url value:builder];
}

- (ThrioFlutterPageBuilder _Nullable)flutterPageBuilder {
  return objc_getAssociatedObject(self, @selector(setFlutterPageBuilder:));
}

- (void)setFlutterPageBuilder:(ThrioFlutterPageBuilder)builder {
  objc_setAssociatedObject(self,
                           @selector(setFlutterPageBuilder:),
                           builder,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - private methods

- (UIViewController *)getPageWithUrl:(NSString *)url
                               index:(NSNumber *)index {
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  if (index && index.integerValue > 0) {
    for (UIViewController *vc in vcs) {
      if ([vc.pageUrl isEqualToString:url] &&
          [vc.pageIndex isEqualToNumber:index]) {
        return vc;
      }
    }
  } else {
    for (UIViewController *vc in vcs) {
      if ([vc.pageUrl isEqualToString:url]) {
        return vc;
      }
    }
  }
  return nil;
}

- (ThrioRegistryMap *)nativePageBuilders {
  return objc_getAssociatedObject(self, @selector(setNativePageBuilders:));
}

- (void)setNativePageBuilders:(ThrioRegistryMap *)builders {
  objc_setAssociatedObject(self,
                           @selector(setNativePageBuilders:),
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
  
  if ([viewController isKindOfClass:ThrioFlutterPage.class]) {
    [[ThrioApp.shared channel] invokeMethod:@"__onPush__" arguments:[viewController pageArguments]];
  }

  [self thrio_pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)thrio_popViewControllerAnimated:(BOOL)animated {
  UIViewController *willPopVC = self.topViewController;
  UIViewController *willShowVC = self.viewControllers[self.viewControllers.count - 2];
  if (willPopVC.hidesNavigationBarWhenPushed != willShowVC.hidesNavigationBarWhenPushed) {
    [self setNavigationBarHidden:willShowVC.hidesNavigationBarWhenPushed];
  }
  
  if ([willPopVC isKindOfClass:ThrioFlutterPage.class]) {
    [[ThrioApp.shared channel] invokeMethod:@"__onPop__" arguments:[willPopVC pageArguments]];
  }
  
  return [self thrio_popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)thrio_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (viewController.hidesNavigationBarWhenPushed != self.topViewController.hidesNavigationBarWhenPushed) {
    [self setNavigationBarHidden:viewController.hidesNavigationBarWhenPushed];
  }
  
  if ([viewController isKindOfClass:ThrioFlutterPage.class]) {
    [[ThrioApp.shared channel] invokeMethod:@"__onPopTo__" arguments:[viewController pageArguments]];
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
