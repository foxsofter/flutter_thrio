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

#import <UIKit/UIKit.h>

#import "NavigatorControllerDelegate.h"
#import "NavigatorLogger.h"
#import "UINavigationController+Navigator.h"

@implementation NavigatorControllerDelegate

- (void)setNavigationController:(UINavigationController *_Nullable)navigationController {
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

#pragma mark - UINavigationControllerDelegate methods

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
            return [self.originDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
        }
    }
    return UIInterfaceOrientationUnknown;
}

- (nullable id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                  interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    id<UIViewControllerInteractiveTransitioning> controller;
    if (self.originDelegate && ![self.originDelegate isEqual:self]) {
        if ([self.originDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
            controller = [self.originDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
        }
    }
    return controller;
}

- (nullable id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                           animationControllerForOperation:(UINavigationControllerOperation)operation
                                                        fromViewController:(UIViewController *)fromVC
                                                          toViewController:(UIViewController *)toVC {
    NavigatorVerbose(@"fromVC: %@ toVC: %@", fromVC, toVC);
    id<UIViewControllerAnimatedTransitioning> animator;
    if (self.originDelegate && ![self.originDelegate isEqual:self]) {
        if ([self.originDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
            animator = [self.originDelegate navigationController:navigationController
                                 animationControllerForOperation:operation
                                              fromViewController:fromVC
                                                toViewController:toVC];
        }
    }
    return animator;
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    if (self.originDelegate && ![self.originDelegate isEqual:self]) {
        if ([self.originDelegate conformsToProtocol:@protocol(UIImagePickerControllerDelegate)] &&
            [self.originDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
            [(id<UIImagePickerControllerDelegate>)self.originDelegate imagePickerController:picker
                                                              didFinishPickingMediaWithInfo:info];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.originDelegate && ![self.originDelegate isEqual:self]) {
        if ([self.originDelegate conformsToProtocol:@protocol(UIImagePickerControllerDelegate)] &&
            [self.originDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            [(id<UIImagePickerControllerDelegate>)self.originDelegate imagePickerControllerDidCancel:picker];
        }
    }
}

@end
