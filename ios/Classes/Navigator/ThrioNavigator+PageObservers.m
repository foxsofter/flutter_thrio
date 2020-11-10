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
#import "ThrioNavigator+PageObservers.h"
#import "NavigatorLogger.h"
#import "ThrioNavigator+Internal.h"
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
    NSEnumerator *allNvcs = self.navigationControllers.allObjects.reverseObjectEnumerator;
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
            [nvc thrio_willAppear:routeSettings
                      routeAction:[self routeActionFromString:routeAction]];
            break;
        }
    }
}

+ (void)didAppear:(NavigatorRouteSettings *)routeSettings
      routeAction:(NSString *)routeAction {
    NSEnumerator *allNvcs = self.navigationControllers.allObjects.reverseObjectEnumerator;
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
            [nvc thrio_didAppear:routeSettings
                     routeAction:[self routeActionFromString:routeAction]];
            break;
        }
    }
}

+ (void)willDisappear:(NavigatorRouteSettings *)routeSettings
          routeAction:(NSString *)routeAction {
    NSEnumerator *allNvcs = self.navigationControllers.allObjects.reverseObjectEnumerator;
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
            [nvc thrio_willDisappear:routeSettings
                         routeAction:[self routeActionFromString:routeAction]];
            break;
        }
    }
}

+ (void)didDisappear:(NavigatorRouteSettings *)routeSettings
         routeAction:(NSString *)routeAction {
    NSEnumerator *allNvcs = self.navigationControllers.allObjects.reverseObjectEnumerator;
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:routeSettings.url index:routeSettings.index]) {
            [nvc thrio_didDisappear:routeSettings
                        routeAction:[self routeActionFromString:routeAction]];
            break;
        }
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
