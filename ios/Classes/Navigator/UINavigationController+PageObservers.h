// The MIT License (MIT)
//
// Copyright (c) 2019 foxsofter
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
#import "NavigatorRouteSettings.h"
#import "NavigatorPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (PageObservers)

/// 处理来自 FlutterEngine 的`willAppear`调用
///
- (void)thrio_willAppear:(NavigatorRouteSettings *)routeSettings
             routeType:(NavigatorRouteType)routeType;

/// 处理来自 FlutterEngine 的`didAppear`调用
///
- (void)thrio_didAppear:(NavigatorRouteSettings *)routeSettings
            routeType:(NavigatorRouteType)routeType;

/// 处理来自 FlutterEngine 的`willDisappear`调用
///
- (void)thrio_willDisappear:(NavigatorRouteSettings *)routeSettings
                routeType:(NavigatorRouteType)routeType;

/// 处理来自 FlutterEngine 的`didDisappear`调用
///
- (void)thrio_didDisappear:(NavigatorRouteSettings *)routeSettings
               routeType:(NavigatorRouteType)routeType;

@end

NS_ASSUME_NONNULL_END
