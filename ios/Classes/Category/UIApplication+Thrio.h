//
//  UIApplication+Thrio.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Thrio)

/// Gets the topmost UIViewController.
///
- (UIViewController *)topmostViewController;

/// Gets the topmost UINavigationController.
///
- (UINavigationController * _Nullable)topmostNavigationController;

@end

NS_ASSUME_NONNULL_END
