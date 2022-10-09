// The MIT License (MIT)
//
// Copyright (c) 2021 foxsofter
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
#import "ThrioModule+RouteObservers.h"
#import "UINavigationController+Navigator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioModule (RouteObservers)

+ (NavigatorRouteObservers *)routeObservers {
    NavigatorRouteObservers *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = [[NavigatorRouteObservers alloc] init];
        objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return value;
}

+ (void)didPush:(NavigatorRouteSettings *)routeSettings {
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    [self.routeObservers didPush:routeSettings];
    [self didPushUrl:routeSettings.url index:routeSettings.index];
}

+ (void)didPop:(NavigatorRouteSettings *)routeSettings {
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    [self.routeObservers didPop:routeSettings];
    [self didPopUrl:routeSettings.url index:routeSettings.index];
}

+ (void)didPopTo:(NavigatorRouteSettings *)routeSettings {
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    [self.routeObservers didPopTo:routeSettings];
    [self didPopToUrl:routeSettings.url index:routeSettings.index];
}

+ (void)didRemove:(NavigatorRouteSettings *)routeSettings {
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    [self.routeObservers didRemove:routeSettings];
    [self didRemoveUrl:routeSettings.url index:routeSettings.index];
}


+ (void)didReplace:(NavigatorRouteSettings *)newRouteSettings
  oldRouteSettings:(NavigatorRouteSettings *)oldRouteSettings {
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     newRouteSettings.url,
                     newRouteSettings.index);
    [self.routeObservers didReplace:newRouteSettings oldRouteSettings:oldRouteSettings];
}

+ (void)didPushUrl:(NSString *)url index:(NSNumber *)index {
    NSArray *allNvcs = [ThrioNavigator.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            [nvc thrio_didPushUrl:url index:index];
            break;
        }
    }
}

+ (void)didPopUrl:(NSString *)url index:(NSNumber *)index {
    NSArray *allNvcs = [ThrioNavigator.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            [nvc thrio_didPopUrl:url index:index];
            break;
        }
    }
}

+ (void)didPopToUrl:(NSString *)url index:(NSNumber *)index {
    NSArray *allNvcs = [ThrioNavigator.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            [nvc thrio_didPopToUrl:url index:index];
            break;
        }
    }
}

+ (void)didRemoveUrl:(NSString *)url index:(NSNumber *)index {
    NSArray *allNvcs = [ThrioNavigator.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            [nvc thrio_didRemoveUrl:url index:index];
            break;
        }
    }
}

@end

NS_ASSUME_NONNULL_END
