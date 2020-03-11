// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.


#import <objc/runtime.h>
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopGesture.h"
#import "UIViewController+WillPopCallback.h"
#import "UIViewController+Internal.h"
#import "UIViewController+Navigator.h"
#import "UIViewController+HidesNavigationBar.h"
#import "NavigatorPageNotifyProtocol.h"
#import "ThrioRegistryMap.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioLogger.h"
#import "NavigatorFlutterEngineFactory.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+NavigatorBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController ()

/// 不是手势触发的当前正要被pop的`UIViewController`
///
@property (nonatomic, strong, nullable) UIViewController *thrio_popingViewController;

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

#pragma mark - navigation methods

- (void)thrio_pushUrl:(NSString *)url
               params:(id _Nullable)params
             animated:(BOOL)animated
       fromEntrypoint:(NSString * _Nullable)entrypoint
               result:(ThrioNumberCallback _Nullable)result
         poppedResult:(ThrioIdCallback _Nullable)poppedResult {
  @synchronized (self) {
    UIViewController *viewController = [self thrio_createNativeViewControllerWithUrl:url params:params];
    if (viewController) {
      [self thrio_pushViewController:viewController
                                 url:url
                              params:params
                            animated:animated
                      fromEntrypoint:entrypoint
                              result:result
                        poppedResult:poppedResult];
    } else {
      NSString *entrypoint = @"";
      if (ThrioNavigator.isMultiEngineEnabled) {
        entrypoint = [url componentsSeparatedByString:@"/"].firstObject;
      }

      __weak typeof(self) weakself = self;
      ThrioIdCallback readyBlock = ^(id _){
        ThrioLogV(@"push entrypoint: %@, url:%@", entrypoint, url);
        __strong typeof(weakself) strongSelf = weakself;
        if ([strongSelf.topViewController isKindOfClass:ThrioFlutterViewController.class] &&
            [[(ThrioFlutterViewController*)strongSelf.topViewController entrypoint] isEqualToString:entrypoint]) {
          NSNumber *index = @([strongSelf thrio_getLastIndexByUrl:url].integerValue + 1);
          [strongSelf.topViewController thrio_pushUrl:url
                                                index:index
                                               params:params
                                             animated:animated
                                       fromEntrypoint:entrypoint
                                               result:^(NSNumber *idx) {
            if (idx) {
              [strongSelf thrio_removePopGesture];
            }
            if (result) {
              result(idx);
            }
          } poppedResult:poppedResult];
        } else {
          UIViewController *viewController = [strongSelf thrio_createFlutterViewControllerWithEntrypoint:entrypoint];
          [strongSelf thrio_pushViewController:viewController
                                           url:url
                                        params:params
                                      animated:animated
                                fromEntrypoint:entrypoint
                                        result:result
                                  poppedResult:poppedResult];
        }
      };

      [NavigatorFlutterEngineFactory.shared startupWithEntrypoint:entrypoint readyBlock:readyBlock];
    }
  }
}

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber * _Nullable)index
                   name:(NSString *)name
                 params:(id _Nullable)params {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if ([vc isKindOfClass:ThrioFlutterViewController.class] ||
      [vc conformsToProtocol:@protocol(NavigatorPageNotifyProtocol)]) {
    return [vc thrio_notifyUrl:url index:index name:name params:params];
  }
  return NO;
}

- (void)thrio_popParams:(id _Nullable)params
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result {
  UIViewController *vc = self.topViewController;
  if (!vc) {
    if (result) {
      result(NO);
    }
    return;
  }
  if (!vc.thrio_firstRoute) { // 不存在表示页面未经过thrio打开，直接关闭即可
    self.thrio_popingViewController = vc;
    id vc = [self popViewControllerAnimated:animated];
    if (result) {
      result(vc != nil);
    }
    return;
  }
  __weak typeof(self) weakself = self;
  [vc thrio_popParams:params animated:animated result:^(BOOL r) {
    __strong typeof(weakself) strongSelf = weakself;
    if (r) {
      // 只有FlutterViewController才能满足条件
      if (vc.thrio_lastRoute != vc.thrio_firstRoute) {
        vc.thrio_lastRoute.prev.next = nil;
        // 只剩一个route的时候，需要添加侧滑返回手势
        if (vc.thrio_firstRoute == vc.thrio_lastRoute) {
          [strongSelf thrio_addPopGesture];
        }
      } else {
        strongSelf.thrio_popingViewController = vc;
        [strongSelf popViewControllerAnimated:animated];
      }
    }
    // 原生页面返回YES不代表已经pop掉页面
    // 如果存在willPop拦截的情况的，视用户决策决定页面是否关闭
    if (result) {
      result(r);
    }
  }];
}

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber * _Nullable)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback _Nullable)result {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    if (result) {
      result(NO);
    }
    return;
  }
  __weak typeof(self) weakself = self;
  [vc thrio_popToUrl:url index:index animated:animated result:^(BOOL r) {
    __strong typeof(weakself) strongSelf = weakself;
    if (r && vc != strongSelf.topViewController) {
      [strongSelf popToViewController:vc animated:animated];
    }
    if (r && vc.thrio_firstRoute == vc.thrio_lastRoute) {
      [strongSelf thrio_addPopGesture];
    }
    if (result) {
      result(r);
    }
  }];
}

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber * _Nullable)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  if (!vc) {
    if (result) {
      result(NO);
    }
    return;
  }
  __weak typeof(self) weakself = self;
  [vc thrio_removeUrl:url index:index animated:animated result:^(BOOL r) {
    __strong typeof(weakself) strongSelf = weakself;
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
    if (result) {
      result(r);
    }
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

- (NSNumber * _Nullable)thrio_lastIndex {
  return self.topViewController.thrio_lastRoute.settings.index;
}

- (NSNumber * _Nullable)thrio_getLastIndexByUrl:(NSString *)url {
  UIViewController *vc = [self getViewControllerByUrl:url index:nil];
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
  return [self getViewControllerByUrl:url index:nil] != nil;
}

- (BOOL)thrio_ContainsUrl:(NSString *)url index:(NSNumber *)index {
  return [self getViewControllerByUrl:url index:index] != nil;
}

- (UIViewController * _Nullable)getViewControllerByUrl:(NSString *)url
                                                 index:(NSNumber * _Nullable)index {
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
  if (self.thrio_popingViewController) { // 不为空表示不是手势触发的pop
    // 如果是FlutterViewController，无视thrio_willPopBlock，willPop在Dart中已经调用过
    if ([self.topViewController isKindOfClass:ThrioFlutterViewController.class]) {
      // 判断前一个页面如果是ThrioFlutterViewController，直接将引擎切换到该页面
      UIViewController *vc = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
      if ([vc isKindOfClass:ThrioFlutterViewController.class]) {
        [NavigatorFlutterEngineFactory.shared pushViewController:(ThrioFlutterViewController*)vc];
      }
      // 判断前一个页面导航栏是否需要切换
      if (self.navigationBarHidden != vc.thrio_hidesNavigationBar.boolValue) {
        [self setNavigationBarHidden:vc.thrio_hidesNavigationBar.boolValue];
      }

      return [self thrio_popViewControllerAnimated:animated];
    }
    
    // 原生页面设置了thrio_willPopBlock
    if (self.topViewController.thrio_willPopBlock && !self.topViewController.thrio_willPopCalling) {
      self.topViewController.thrio_willPopCalling = YES;
      __weak typeof(self) weakself = self;
      self.topViewController.thrio_willPopBlock(^(BOOL result) {
        __strong typeof(weakself) strongSelf = weakself;
        if (result) {
          [strongSelf thrio_popViewControllerAnimated:animated];
          
          // 确定要关闭页面，thrio_willPopBlock需要设为nil
          strongSelf.topViewController.thrio_willPopBlock = nil;
        }
        // 是否调用willPop的标记位恢复NO
        strongSelf.topViewController.thrio_willPopCalling = NO;
      });
      return nil;
    }
    self.thrio_popingViewController = nil;
  } else {
    // 手势触发的，记录下作为标记位供`thrio_didShowViewController:animated:`判断
    self.thrio_popingViewController = self.topViewController;
  }
  
  return [self thrio_popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> * _Nullable)thrio_popToViewController:(UIViewController *)viewController
                                                                     animated:(BOOL)animated {
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
  // 如果即将显示的页面为ThrioFlutterViewController，需要将该页面切换到引擎上
  if ([viewController isKindOfClass:ThrioFlutterViewController.class]) {
    [NavigatorFlutterEngineFactory.shared pushViewController:(ThrioFlutterViewController*)viewController];
  }
  // 手势触发的pop，或者UINavigationController的pop方法触发的pop
  if (self.thrio_popingViewController) {
    __weak typeof(self) weakself = self;
    [self.thrio_popingViewController thrio_popParams:nil animated:animated result:^(BOOL r) {
      __strong typeof(weakself) strongSelf = weakself;
      // 刚关掉的是ThrioFlutterViewController，且当前要显示的页面不是ThrioFlutterViewController，置空引擎的viewController
      if ([strongSelf.thrio_popingViewController isKindOfClass:ThrioFlutterViewController.class]) {
        if (![viewController isKindOfClass:ThrioFlutterViewController.class]) {
          [NavigatorFlutterEngineFactory.shared popViewController:(ThrioFlutterViewController*)strongSelf.thrio_popingViewController];
        }
        if (strongSelf.navigationBarHidden != viewController.thrio_hidesNavigationBar.boolValue) {
          [strongSelf setNavigationBarHidden:viewController.thrio_hidesNavigationBar.boolValue];
        }
      }
      strongSelf.thrio_popingViewController = nil;
    }];
  }
}

#pragma mark - private methods

- (UIViewController *)thrio_createFlutterViewControllerWithEntrypoint:(NSString *)entrypoint {
  UIViewController *viewController;
  ThrioFlutterViewControllerBuilder flutterBuilder = [ThrioNavigator flutterViewControllerBuilder];
  if (flutterBuilder) {
    viewController = flutterBuilder();
  } else {
    viewController = [[ThrioFlutterViewController alloc] initWithEntrypoint:entrypoint];
  }
  return viewController;
}

- (UIViewController * _Nullable)thrio_createNativeViewControllerWithUrl:(NSString *)url params:(NSDictionary *)params {
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
  }
  return viewController;
}

- (void)thrio_pushViewController:(UIViewController *)viewController
                             url:(NSString *)url
                          params:(id _Nullable)params
                        animated:(BOOL)animated
                  fromEntrypoint:(NSString * _Nullable)entrypoint
                          result:(ThrioNumberCallback _Nullable)result
                    poppedResult:(ThrioIdCallback _Nullable)poppedResult {
  if (viewController) {
    NSNumber *index = @([self thrio_getLastIndexByUrl:url].integerValue + 1);
    __weak typeof(self) weakself = self;
    [viewController thrio_pushUrl:url
                            index:index
                           params:params
                         animated:animated
                   fromEntrypoint:entrypoint
                           result:^(NSNumber *idx) {
      if (idx) {
        __strong typeof(weakself) strongSelf = weakself;
        [strongSelf pushViewController:viewController animated:animated];
      }
      if (result) {
        result(idx);
      }
    } poppedResult:poppedResult];
  }
}

@end

NS_ASSUME_NONNULL_END
