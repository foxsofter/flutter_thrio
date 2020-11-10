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

#import "UINavigationController+PageObservers.h"
#import "UINavigationController+Navigator.h"
#import "UIViewController+Navigator.h"
#import "ThrioNavigator+PageObservers.h"

@implementation UINavigationController (PageObservers)

- (void)thrio_willAppear:(NavigatorRouteSettings *)routeSettings
             routeAction:(NavigatorRouteAction)routeAction {
    NavigatorPageRoute *route = [self.topViewController thrio_getRouteByUrl:routeSettings.url
                                                                      index:routeSettings.index];
    if (!route) {
        return;
    }
    if (routeAction == NavigatorRouteActionPush) {
        NavigatorPageRoute *lastRoute = [self.topViewController thrio_lastRoute];
        if (route != lastRoute) {
            return;
        }

        // 触发所有 observer 的 `willAppear`
        [ThrioNavigator.pageObservers willAppear:routeSettings];
        // 如果存在前序的 route，触发其 `willDisappear`
        if (lastRoute.prev) {
            [ThrioNavigator.pageObservers willDisappear:lastRoute.prev.settings];
        }
    } else if (routeAction == NavigatorRouteActionPopTo) {
        NavigatorPageRoute *lastRoute = [self.topViewController thrio_lastRoute];
        if (route == lastRoute) {
            return;
        }
        // 触发所有 observer 的 `willAppear`
        [ThrioNavigator.pageObservers willAppear:routeSettings];
        // 触发顶部 route 的 `willDisappear`
        if (lastRoute) {
            [ThrioNavigator.pageObservers willDisappear:lastRoute.settings];
        }
    }
}

- (void)thrio_didAppear:(NavigatorRouteSettings *)routeSettings
            routeAction:(NavigatorRouteAction)routeAction {
    NavigatorPageRoute *route = [self.topViewController thrio_getRouteByUrl:routeSettings.url
                                                                      index:routeSettings.index];
    if (!route) {
        return;
    }
    if (routeAction == NavigatorRouteActionPush) {
        NavigatorPageRoute *lastRoute = [self.topViewController thrio_lastRoute];
        if (route != lastRoute) {
            return;
        }

        // 触发所有 observer 的 `willAppear`
        [ThrioNavigator.pageObservers willAppear:routeSettings];
        // 如果存在前序的 route，触发其 `willDisappear`
        if (lastRoute.prev) {
            [ThrioNavigator.pageObservers willDisappear:lastRoute.prev.settings];
        }
    } else if (routeAction == NavigatorRouteActionPopTo) {
        NavigatorPageRoute *lastRoute = [self.topViewController thrio_lastRoute];
        if (route == lastRoute) {
            return;
        }
        // 触发所有 observer 的 `willAppear`
        [ThrioNavigator.pageObservers willAppear:routeSettings];
        // 触发顶部 route 的 `willDisappear`
        if (lastRoute) {
            [ThrioNavigator.pageObservers willDisappear:lastRoute.settings];
        }
    }
}

- (void)thrio_willDisappear:(NavigatorRouteSettings *)routeSettings
                routeAction:(NavigatorRouteAction)routeAction {
}

- (void)thrio_didDisappear:(NavigatorRouteSettings *)routeSettings
               routeAction:(NavigatorRouteAction)routeAction {
}

@end
