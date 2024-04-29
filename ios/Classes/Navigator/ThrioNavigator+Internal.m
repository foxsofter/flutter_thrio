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

#import "NSPointerArray+Thrio.h"
#import "NavigatorConsts.h"
#import "NavigatorFlutterEngineFactory.h"
#import "ThrioModule+PageBuilders.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioRegistrySet.h"
#import "UIApplication+Thrio.h"
#import "UINavigationController+HotRestart.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopDisabled.h"
#import "UINavigationController+PopGesture.h"
#import "UIViewController+Navigator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator (Internal)

+ (UINavigationController *_Nullable)navigationController {
    return [[UIApplication sharedApplication] topmostNavigationController];
}

+ (NSPointerArray *)navigationControllers {
    static NSPointerArray *controllers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controllers = [NSPointerArray weakObjectsPointerArray];
    });
    if (controllers.count < 1) {
        id nvc = [[UIApplication sharedApplication] topmostNavigationController];
        if (nvc) {
            [controllers addObject:nvc];
        }
    }
    return controllers;
}

+ (void)_pushUrl:(NSString *)url
          params:(id _Nullable)params
        animated:(BOOL)animated
  fromEntrypoint:fromEntrypoint
          result:(ThrioNumberCallback _Nullable)result
         fromURL:(NSString *_Nullable)fromURL
         prevURL:(NSString *_Nullable)prevURL
        innerURL:(NSString *_Nullable)innerURL
    poppedResult:(ThrioIdCallback _Nullable)poppedResult
{
    UINavigationController *nvc = self.navigationController;
    [self.navigationControllers addAndRemoveObject:nvc];
    if (!prevURL) {
        prevURL = [ThrioNavigator lastRoute].settings.url;
    }
    [nvc thrio_pushUrl:url
                params:params
              animated:animated
        fromEntrypoint:fromEntrypoint
                result:^(NSNumber *idx) {
        if (result) {
            result(idx);
        }
    }
               fromURL:fromURL
               prevURL:prevURL
              innerURL:innerURL
          poppedResult:poppedResult];
}

+ (void)_notifyUrl:(NSString *_Nullable)url
             index:(NSNumber *_Nullable)index
              name:(NSString *)name
            params:(id _Nullable)params
            result:(ThrioBoolCallback _Nullable)result {
    // 给所有的 UINavigationController 发通知
    BOOL canNotify = YES;
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        if (![nvc thrio_notifyUrl:url index:index name:name params:params]) {
            canNotify = NO;
        }
    }
    if (result) {
        result(canNotify);
    }
}

+ (void)_popParams:(id _Nullable)params
          animated:(BOOL)animated
            result:(ThrioBoolCallback _Nullable)result {
    [self.navigationController thrio_popParams:params
                                      animated:animated
                                        result:result];
}

+ (void)_popFlutterParams:(id _Nullable)params
                 animated:(BOOL)animated
                   result:(ThrioBoolCallback _Nullable)result {
    [self.navigationController thrio_popFlutterParams:params
                                             animated:animated
                                               result:result];
}

+ (void)_maybePopParams:(id _Nullable)params
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result {
    [self.navigationController thrio_maybePopParams:params
                                           animated:animated
                                             result:result];
}


+ (void)_popToUrl:(NSString *)url
            index:(NSNumber *_Nullable)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback _Nullable)result {
    UINavigationController *nvc = self.navigationController;
    if ([nvc thrio_containsUrl:url index:index]) {
        [nvc thrio_popToUrl:url index:index animated:animated result:result];
    } else {
        if (result) {
            result(NO);
        }
    }
}

+ (void)_removeUrl:(NSString *)url
             index:(NSNumber *_Nullable)index
          animated:(BOOL)animated
            result:(ThrioBoolCallback _Nullable)result {
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    BOOL contains = NO;
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            contains = YES;
            [nvc thrio_removeUrl:url index:index animated:animated result:result];
            break;
        }
    }
    if (!contains) {
        if (result) {
            result(NO);
        }
    }
}

+ (void)_replaceUrl:(NSString *)url
              index:(NSNumber *_Nullable)index
             newUrl:(NSString *)newUrl
             result:(ThrioNumberCallback _Nullable)result {
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    BOOL contains = NO;
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            contains = YES;
            [nvc thrio_replaceUrl:url
                            index:index
                           newUrl:newUrl
                           result:result];
            break;
        }
    }
    if (!contains) {
        if (result) {
            result(@0);
        }
    }
}

+ (void)_canPop:(ThrioBoolCallback _Nullable)result {
    UINavigationController *nvc = self.navigationController;
    UIViewController *topVC = [[UIApplication sharedApplication] topmostViewController];
    UIViewController *curVC = nvc.viewControllers.lastObject;
    if (topVC != curVC) {
        if (result) {
            result(NO);
        }
        return;
    }
    BOOL inRoot = topVC == nvc.viewControllers.firstObject;
    [topVC thrio_canPopInRoot:inRoot result:result];
}

+ (NSArray *)_getAllRoutesByUrl:(NSString *_Nullable)url {
    NSMutableArray *allRoutes = [NSMutableArray array];
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        NSArray *routes = [nvc thrio_getAllRoutesByUrl:url];
        if (routes.count > 0) {
            [allRoutes addObjectsFromArray:routes];
        }
    }
    return allRoutes;
}

+ (void)_setPopDisabledUrl:(NSString *)url index:(NSNumber *)index disabled:(BOOL)disabled {
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        if ([nvc thrio_containsUrl:url index:index]) {
            [nvc thrio_setPopDisabledUrl:url index:index disabled:disabled];
            break;
        }
    }
}

+ (void)_hotRestart:(ThrioBoolCallback)result {
    NSArray *allNvcs = self.navigationControllers.allObjects;
    BOOL foundFlutterVC = NO;
    for (UINavigationController *nvc in allNvcs) {
        if (foundFlutterVC) {
            if (nvc.tabBarController) {
                [nvc popToRootViewControllerAnimated:NO];
            } else {
                [nvc dismissViewControllerAnimated:NO completion:nil];
            }
        } else {
            NSArray *vcs = [nvc viewControllers];
            for (UIViewController *vc in vcs) {
                if ([vc isKindOfClass:NavigatorFlutterViewController.class]) {
                    foundFlutterVC = YES;
                    break;
                }
            }
            if (foundFlutterVC) {
                [nvc thrio_hotRestart:result];
            }
        }
    }
}

+ (NavigatorPageRoute *_Nullable)_getLastRouteByEntrypoint:(NSString *)entrypoint {
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        NavigatorPageRoute *route = [nvc thrio_getLastRouteByEntrypoint:entrypoint];
        if (route) {
            return route;
        }
    }
    return nil;
}

@end

NS_ASSUME_NONNULL_END
