//
//  ThrioNavigationControllerDelegate.m
//  thrio
//
//  Created by Wei ZhongDan on 2020/1/30.
//

#import "ThrioNavigationControllerDelegate.h"
#import "ThrioFlutterViewController.h"
#import "UINavigationController+ThrioNavigator.h"

@implementation ThrioNavigationControllerDelegate

- (void)setNavigationController:(UINavigationController * _Nullable)navigationController {
  _originDelegate = navigationController.delegate;
  _navigationController = navigationController;
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if (self.originDelegate && ![self.originDelegate isEqual:self]) {
    if ([self.originDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
      [self.originDelegate navigationController:navigationController
                          didShowViewController:viewController
                                       animated:animated];
    }
  }
    // 让系统的侧滑返回生效
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  if (self.navigationController.viewControllers.count > 0) {
    if (viewController == self.navigationController.viewControllers.firstObject) {
      self.navigationController.interactivePopGestureRecognizer.delegate = self.navigationController.thrio_popGestureRecognizerDelegate; // 不支持侧滑
    } else {
      self.navigationController.interactivePopGestureRecognizer.delegate = nil; // 支持侧滑
    }
  }

  if ([viewController isKindOfClass:ThrioFlutterViewController.class]) {
    UIPanGestureRecognizer *popRecognizer = self.navigationController.thrio_popGestureRecognizer;
    if (![viewController.view.gestureRecognizers containsObject:popRecognizer]) {
      [viewController.view addGestureRecognizer:popRecognizer];
    }
  }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if (self.originDelegate && ![self.originDelegate isEqual:self]) {
    if ([self.originDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
      [self.originDelegate navigationController:navigationController
                         willShowViewController:viewController
                                       animated:animated];
    }
  }
}

@end
