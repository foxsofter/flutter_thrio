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
#import "NavigatorLogger.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator+PageObservers.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PageObservers.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator (PageObservers)

+ (NavigatorPageObservers *)pageObservers {
    id value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = [[NavigatorPageObservers alloc] init];
        objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return value;
}

+ (void)willAppear:(NavigatorRouteSettings *)routeSettings
       routeAction:(NSString *)routeAction {
    NavigatorRouteAction action = [self routeActionFromString:routeAction];
    UINavigationController *nvc = self.navigationController;
    if (action == NavigatorRouteActionPush) {
        [ThrioNavigator.pageObservers willAppear:routeSettings];
        NavigatorPageRoute *lastRoute = nvc.thrio_lastRoute;
        if (![lastRoute.settings isEqualToRouteSettings:routeSettings]) {
            [ThrioNavigator.pageObservers willDisappear:lastRoute.settings];
        }
    } else if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
        [nvc thrio_willAppear:routeSettings routeAction:action];
    }
}

+ (void)didAppear:(NavigatorRouteSettings *)routeSettings
      routeAction:(NSString *)routeAction {
    NavigatorRouteAction action = [self routeActionFromString:routeAction];
    UINavigationController *nvc = self.navigationController;
    if (action == NavigatorRouteActionPush) {
        [ThrioNavigator.pageObservers didAppear:routeSettings];
        NavigatorPageRoute *lastRoute = nvc.thrio_lastRoute;
        [ThrioNavigator.pageObservers didDisappear:lastRoute.settings];
    } else if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
        [nvc thrio_didAppear:routeSettings routeAction:action];
    }
}

+ (void)willDisappear:(NavigatorRouteSettings *)routeSettings
          routeAction:(NSString *)routeAction {
    NavigatorRouteAction action = [self routeActionFromString:routeAction];
    UINavigationController *nvc = self.navigationController;
    if (action == NavigatorRouteActionPop || action == NavigatorRouteActionRemove) {
        NavigatorPageRoute *lastRoute = nvc.thrio_lastRoute;
        if ([lastRoute.settings isEqualToRouteSettings:routeSettings]) {
            [ThrioNavigator.pageObservers willDisappear:routeSettings];
            [ThrioNavigator.pageObservers willAppear:lastRoute.prev.settings];
        }
    } else if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
        [nvc thrio_willDisappear:routeSettings routeAction:action];
    }
}

+ (void)didDisappear:(NavigatorRouteSettings *)routeSettings
         routeAction:(NSString *)routeAction {
    NavigatorRouteAction action = [self routeActionFromString:routeAction];
    UINavigationController *nvc = self.navigationController;
    if (action == NavigatorRouteActionPop || action == NavigatorRouteActionRemove) {
        NavigatorPageRoute *prevLastRoute = ThrioNavigator.pageObservers.prevLastRoute;
        if ([prevLastRoute.settings isEqualToRouteSettings:routeSettings]) {
            [ThrioNavigator.pageObservers didDisappear:routeSettings];
            [ThrioNavigator.pageObservers didAppear:prevLastRoute.prev.settings];
        }
    } else if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
        [nvc thrio_didDisappear:routeSettings routeAction:action];
    }
}

+ (NavigatorRouteAction)routeActionFromString:(NSString *)routeActionString {
    if ([routeActionString isEqualToString:@"push"]) {
        return NavigatorRouteActionPush;
    } else if ([routeActionString isEqualToString:@"pop"]) {
        return NavigatorRouteActionPop;
    } else if ([routeActionString isEqualToString:@"popTo"]) {
        return NavigatorRouteActionPopTo;
    } else if ([routeActionString isEqualToString:@"remove"]) {
        return NavigatorRouteActionRemove;
    }
    return NavigatorRouteActionNone;
}

@end

NS_ASSUME_NONNULL_END
