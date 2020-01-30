//
//  ThrioPopGestureRecognizerDelegate.m
//  thrio
//
//  Created by Wei ZhongDan on 2020/1/30.
//

#import "ThrioPopGestureRecognizerDelegate.h"
#import "UIViewController+ThrioPageRoute.h"
#import "ThrioFlutterViewController.h"

@implementation ThrioPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
  UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
  
  if (topViewController.thrio_popDisabled) {
    return NO;
  }
    
  // Ignore when no view controller is pushed into the navigation stack.
  if (self.navigationController.viewControllers.count <= 1) {
    return NO;
  }

  // Ignore pan gesture when the navigation controller is currently in transition.
  if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
    return NO;
  }

  // Ignore when the beginning location is beyond max allowed initial distance to left edge.
//  CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
//  if (beginningLocation.x > 0) {
//    return NO;
//  }

  // Prevent calling the handler when the gesture begins in an opposite direction.
  CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
  BOOL isLeftToRight = [UIApplication sharedApplication]
    .userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
  CGFloat multiplier = isLeftToRight ? 1 : - 1;
  if ((translation.x * multiplier) <= 0) {
    return NO;
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

@end
