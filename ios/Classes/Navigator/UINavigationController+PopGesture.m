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

#import <objc/runtime.h>
#import "NSObject+ThrioSwizzling.h"
#import "UINavigationController+PopGesture.h"

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

- (NavigatorPopGestureRecognizerDelegate *)thrio_popGestureRecognizerDelegate {
    NavigatorPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[NavigatorPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        objc_setAssociatedObject(self,
                                 _cmd,
                                 delegate,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (NavigatorControllerDelegate *)thrio_navigationControllerDelegate {
    NavigatorControllerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[NavigatorControllerDelegate alloc] init];
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
        [self instanceSwizzle:@selector(setDelegate:) newSelector:@selector(thrio_setDelegate:)];
    });
}

/// Make sure that external delegate can take effect.
///
- (void)thrio_setDelegate:(id<UINavigationControllerDelegate> _Nullable)delegate {
    if (!self.delegate) {
        [self setValue:self.thrio_navigationControllerDelegate forKey:@"_delegate"];
    }
    if (delegate != self.thrio_navigationControllerDelegate) {
        self.thrio_navigationControllerDelegate.originDelegate = delegate;
    }
}

@end
