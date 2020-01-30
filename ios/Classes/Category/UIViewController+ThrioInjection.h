//
//  UIViewController+ThrioInjection.h
//  thrio
//
//  Created by Wei ZhongDan on 2020/1/29.
//

#import <UIKit/UIKit.h>

#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ThrioViewControllerLifecycleInjectionBlock)(UIViewController *viewController, BOOL animated);

typedef NS_ENUM(NSUInteger, ThrioViewControllerLifecycle) {
  ThrioViewControllerLifecycleViewWillAppear,
  ThrioViewControllerLifecycleViewDidAppear,
  ThrioViewControllerLifecycleViewWillDisappear,
  ThrioViewControllerLifecycleViewDidDisappear,
};

@interface UIViewController (ThrioInjection)

- (ThrioVoidCallback)registerInjectionBlock:(ThrioViewControllerLifecycleInjectionBlock)block
                            beforeLifecycle:(ThrioViewControllerLifecycle)lifecycle;

- (ThrioVoidCallback)registerInjectionBlock:(ThrioViewControllerLifecycleInjectionBlock)block
                             afterLifecycle:(ThrioViewControllerLifecycle)lifecycle;

@end

NS_ASSUME_NONNULL_END
