//
//  ThrioPopGestureRecognizerDelegate.m
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import "ThrioPopGestureRecognizerDelegate.h"
#import "UIViewController+Navigator.h"

@implementation ThrioPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
  UIViewController *topViewController = self.navigationController.topViewController;
  if (topViewController.thrio_lastRoute.popDisabled) {
    return NO;
  }
    
  if (self.navigationController.viewControllers.count <= 1) {
    return NO;
  }

  if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
    return NO;
  }
  
  return YES;
}

@end
