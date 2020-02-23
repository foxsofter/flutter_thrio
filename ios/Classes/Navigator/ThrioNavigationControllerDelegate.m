//
//  ThrioNavigationControllerDelegate.m
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import "ThrioNavigationControllerDelegate.h"
#import "UINavigationController+Navigator.h"

@implementation ThrioNavigationControllerDelegate

- (void)setNavigationController:(UINavigationController * _Nullable)navigationController {
  _originDelegate = navigationController.delegate;
  _navigationController = navigationController;
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
  [self.navigationController thrio_didShowViewController:viewController animated:animated];
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
  if (self.originDelegate && ![self.originDelegate isEqual:self]) {
    if ([self.originDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
      return [self.originDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
  }
  return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
  if (self.originDelegate && ![self.originDelegate isEqual:self]) {
    if ([self.originDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
      return [self.originDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
  }
  return UIInterfaceOrientationUnknown;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {

  if (self.originDelegate && ![self.originDelegate isEqual:self]) {
    if ([self.originDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
      return [self.originDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
  }
  return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
  if (self.originDelegate && ![self.originDelegate isEqual:self]) {
    if ([self.originDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
      [self.originDelegate navigationController:navigationController
                animationControllerForOperation:operation
                             fromViewController:fromVC
                               toViewController:toVC];
    }
  }
  return nil;
}

@end
