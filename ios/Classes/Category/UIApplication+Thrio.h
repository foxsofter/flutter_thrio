//
//  UIApplication+Thrio.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Thrio)

- (UIViewController *)topmostViewController;

- (UINavigationController *)topmostNavigationController;

@end

NS_ASSUME_NONNULL_END
