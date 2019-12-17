//
//  UIApplication+ThrioTopmost.h
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (ThrioTopmost)

- (UIViewController *)topmostViewController;

- (UINavigationController *)topmostNavigationController;

@end

NS_ASSUME_NONNULL_END
