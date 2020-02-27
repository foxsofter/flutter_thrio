//
//  UINavigationController+PopGesture.m
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import <objc/runtime.h>
#import "UINavigationController+PopGesture.h"
#import "NSObject+ThrioSwizzling.h"

@implementation UINavigationController (PopGesture)

- (UIScreenEdgePanGestureRecognizer *)thrio_popGestureRecognizer {
  UIScreenEdgePanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
  if (!panGestureRecognizer) {
    panGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self.thrio_popGestureRecognizerDelegate;
    panGestureRecognizer.delaysTouchesBegan = YES;
    panGestureRecognizer.edges = UIRectEdgeLeft;
    id target = self.interactivePopGestureRecognizer.delegate;
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    [panGestureRecognizer addTarget:target action:action];

    objc_setAssociatedObject(self,
                             _cmd,
                             panGestureRecognizer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return panGestureRecognizer;
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

- (void)thrio_addPopGesture {
  if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.thrio_popGestureRecognizer]) {
    [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.thrio_popGestureRecognizer];
  }
  self.delegate = self.thrio_navigationControllerDelegate;
  self.interactivePopGestureRecognizer.enabled = NO;
}

- (void)thrio_removePopGesture {
  if ([self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.thrio_popGestureRecognizer]) {
    [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.thrio_popGestureRecognizer];
  }
  self.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - method swizzling

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self instanceSwizzle:@selector(setDelegate:)
              newSelector:@selector(thrio_setDelegate:)];
  });
}

/// Make sure that external delegate can take effect.
///
- (void)thrio_setDelegate:(id<UINavigationControllerDelegate> _Nullable)delegate {
  if (self.delegate == delegate) {
    return;
  }
  if (self.delegate == self.thrio_navigationControllerDelegate) {
    self.thrio_navigationControllerDelegate.originDelegate = delegate;
  } else {
    [self setValue:delegate forKey:@"_delegate"];
  }
}

@end
