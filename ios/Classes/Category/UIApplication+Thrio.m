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

#import "UIApplication+Thrio.h"

@implementation UIApplication (Thrio)

- (UIViewController *)topmostViewController {
    UIViewController *topmostViewController = self.delegate.window.rootViewController;
    while (true) {
        if (topmostViewController.presentedViewController) {
            topmostViewController = topmostViewController.presentedViewController;
        } else if ([topmostViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)topmostViewController;
            topmostViewController = navigationController.topViewController;
        } else if ([topmostViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *)topmostViewController;
            topmostViewController = tabBarController.selectedViewController;
        } else {
            break;
        }
    }
    return topmostViewController;
}

- (UINavigationController *_Nullable)topmostNavigationController {
    UINavigationController *topmostNavigationController = nil;
    UIViewController *topmostViewController = self.delegate.window.rootViewController;
    while (true) {
        if ([topmostViewController isKindOfClass:[UINavigationController class]]) {
            topmostNavigationController = (UINavigationController *)topmostViewController;
        }
        if (topmostViewController.presentedViewController) {
            topmostViewController = topmostViewController.presentedViewController;
        } else if ([topmostViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *)topmostViewController;
            topmostViewController = tabBarController.selectedViewController;
        } else {
            break;
        }
    }
    return topmostNavigationController;
}

@end
