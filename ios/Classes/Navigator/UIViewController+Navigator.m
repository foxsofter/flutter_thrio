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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "NavigatorConsts.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterViewController.h"
#import "NavigatorLogger.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioModule+JsonDeserializers.h"
#import "ThrioModule+JsonSerializers.h"
#import "ThrioModule+PageObservers.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopGesture.h"
#import "UIViewController+HidesNavigationBar.h"
#import "UIViewController+Internal.h"
#import "UIViewController+Navigator.h"
#import "UIViewController+WillPopCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()

@property (nonatomic, strong, readwrite, nullable) NavigatorPageRoute *thrio_firstRoute;

@end

@implementation UIViewController (Navigator)

- (NavigatorPageRoute *_Nullable)thrio_firstRoute {
    return objc_getAssociatedObject(self, @selector(setThrio_firstRoute:));
}

- (void)setThrio_firstRoute:(NavigatorPageRoute *_Nullable)route {
    objc_setAssociatedObject(self,
                             @selector(setThrio_firstRoute:),
                             route,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NavigatorPageRoute *_Nullable)thrio_lastRoute {
    NavigatorPageRoute *next = self.thrio_firstRoute;
    while (next.next)
        next = next.next;
    return next;
}

- (NavigatorRouteType)thrio_routeType {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(setThrio_routeType:)) integerValue];
}

- (void)setThrio_routeType:(NavigatorRouteType)routeType {
    objc_setAssociatedObject(self,
                             @selector(setThrio_routeType:),
                             @(routeType),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Navigation methods

- (void)thrio_pushUrl:(NSString *)url
                index:(NSNumber *)index
               params:(id _Nullable)params
             animated:(BOOL)animated
       fromEntrypoint:(NSString *_Nullable)fromEntrypoint
           fromPageId:(NSUInteger)fromPageId
               result:(ThrioNumberCallback _Nullable)result
         poppedResult:(ThrioIdCallback _Nullable)poppedResult {
    if (self.thrio_routeType != NavigatorRouteTypeNone) {
        if (result) {
            result(@0);
        }
    }
    self.thrio_routeType = NavigatorRouteTypePushing;
    
    NavigatorRouteSettings *settings = [NavigatorRouteSettings settingsWithUrl:url
                                                                         index:index
                                                                        nested:self.thrio_firstRoute != nil
                                                                        params:params];
    NavigatorPageRoute *newRoute = [NavigatorPageRoute routeWithSettings:settings];
    newRoute.fromEntrypoint = fromEntrypoint;
    newRoute.fromPageId = fromPageId;
    newRoute.poppedResult = poppedResult;
    
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
        id serializeParams = [ThrioModule serializeParams:params];
        NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithDictionary:[settings toArgumentsWithParams:serializeParams]];
        [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
        NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
        NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
        NavigatorRouteSendChannel *channel =
        [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId withEntrypoint:entrypoint];
        __weak typeof(self) weakSelf = self;
        [channel push:arguments result:^(BOOL r) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (r) {
                if (strongSelf.thrio_firstRoute) {
                    NavigatorPageRoute *lastRoute = strongSelf.thrio_lastRoute;
                    lastRoute.next = newRoute;
                    newRoute.prev = lastRoute;
                } else {
                    strongSelf.thrio_firstRoute = newRoute;
                }
                
                ThrioModule.pageObservers.lastRoute = newRoute;
            }
            if (result) {
                result(r ? index : @0);
            }
            strongSelf.thrio_routeType = NavigatorRouteTypeNone;
        }];
    } else {
        if (self.thrio_firstRoute) {
            NavigatorPageRoute *lastRoute = self.thrio_lastRoute;
            lastRoute.next = newRoute;
            newRoute.prev = lastRoute;
        } else {
            self.thrio_firstRoute = newRoute;
        }
        
        ThrioModule.pageObservers.lastRoute = newRoute;
        if (result) {
            result(index);
        }
        self.thrio_routeType = NavigatorRouteTypeNone;
    }
}

- (BOOL)thrio_notifyUrl:(NSString *_Nullable)url
                  index:(NSNumber *_Nullable)index
                   name:(NSString *)name
                 params:(id _Nullable)params {
    BOOL isMatch = NO;
    
    NavigatorPageRoute *last = self.thrio_lastRoute;
    do {
        if ((url == nil || [last.settings.url isEqualToString:url]) &&
            (index == nil || [index isEqualToNumber:@0] || [last.settings.index isEqualToNumber:index])) {
            [last addNotify:name params:params];
            if (self == self.navigationController.topViewController &&
                last == self.thrio_lastRoute) {
                [self thrio_onNotify:last];
            }
            isMatch = YES;
        }
    } while ((last = last.prev));
    
    return isMatch;
}

- (void)thrio_maybePopParams:(id _Nullable)params
                    animated:(BOOL)animated
                      inRoot:(BOOL)inRoot
                      result:(ThrioNumberCallback _Nullable)result {
    NavigatorPageRoute *route = self.thrio_lastRoute;
    if (!route) {
        if (result) {
            result(@0);
        }
        return;
    }
    id serializeParams = [ThrioModule serializeParams:params];
    NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings
                                                   toArgumentsWithParams:serializeParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    [arguments setObject:[NSNumber numberWithBool:inRoot] forKey:@"inRoot"];
    
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
        NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
        NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
        NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId
                                                                                           withEntrypoint:entrypoint];
        // 发送给需要关闭页面的引擎
        [channel maybePop:arguments result:result];
    } else {
        if (result) {
            // TODO: 原生页面也需要判断 willPop
            result(@1);
        }
    }
}

- (void)thrio_popParams:(id _Nullable)params
               animated:(BOOL)animated
                 inRoot:(BOOL)inRoot
                 result:(ThrioBoolCallback _Nullable)result {
    NavigatorPageRoute *route = self.thrio_lastRoute;
    if (!route || self.thrio_routeType != NavigatorRouteTypeNone) {
        if (result) {
            result(NO);
        }
        return;
    }
    id serializeParams = [ThrioModule serializeParams:params];
    NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings
                                                   toArgumentsWithParams:serializeParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    [arguments setObject:[NSNumber numberWithBool:inRoot] forKey:@"inRoot"];
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
        self.thrio_routeType = NavigatorRouteTypePopping;
        NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
        NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
        NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId
                                                                                           withEntrypoint:entrypoint];
        __weak typeof(self) weakself = self;
        // 发送给需要关闭页面的引擎
        [channel pop:arguments result:^(BOOL r) {
            __strong typeof(weakself) strongSelf = weakself;
            if (r) {
                if (route != strongSelf.thrio_firstRoute) {
                    ThrioModule.pageObservers.lastRoute = route.prev;
                    [strongSelf thrio_onNotify:route.prev];
                } else {
                    [strongSelf.navigationController popViewControllerAnimated:animated];
                }
            }
            strongSelf.thrio_routeType = NavigatorRouteTypeNone;
            if (result) {
                result(r);
            }
            
            // 关闭成功,处理页面回传参数
            if (r) {
                if (route.poppedResult) {
                    id deserializeParams = [ThrioModule deserializeParams:params];
                    route.poppedResult(deserializeParams);
                }
                // 检查打开页面的源引擎是否和关闭页面的源引擎不同，不同则继续发送onPop
                if (route.fromEntrypoint && route.fromPageId != kNavigatorRoutePageIdNone &&
                    !([route.fromEntrypoint isEqualToString:entrypoint] && route.fromPageId == pageId)) {
                    NavigatorRouteSendChannel *channel =
                    [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:route.fromPageId
                                                                  withEntrypoint:route.fromEntrypoint];
                    [channel pop:arguments result:nil];
                }
            }
        }];
    } else {
        if (result) {
            // 原生页面一定只有一个route
            result(route == self.thrio_firstRoute);
        }
        if (route == self.thrio_firstRoute) {
            // 关闭成功,处理页面回传参数
            if ([self.navigationController popViewControllerAnimated:animated]) {
                if (route.poppedResult) {
                    id deserializeParams = [ThrioModule deserializeParams:params];
                    route.poppedResult(deserializeParams);
                }
                // 检查打开页面的源引擎是否来自Flutter引擎，是则发送onPop
                if (route.fromEntrypoint && route.fromPageId != kNavigatorRoutePageIdNone) {
                    NavigatorRouteSendChannel *channel =
                    [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:route.fromPageId
                                                                  withEntrypoint:route.fromEntrypoint];
                    [channel pop:arguments result:nil];
                }
            }
        }
    }
}

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *_Nullable)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback _Nullable)result {
    NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
    if (!route) {
        if (result) {
            result(NO);
        }
        return;
    }
    // 是最顶层页面，无法popTo
    if (self.thrio_lastRoute == route && self == self.navigationController.topViewController) {
        if (result) {
            result(NO);
        }
        return;
    }
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
        NSMutableDictionary *arguments =
        [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithParams:nil]];
        [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
        __weak typeof(self) weakself = self;
        NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
        NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
        NavigatorRouteSendChannel *channel =
        [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId
                                                      withEntrypoint:entrypoint];
        [channel popTo:arguments result:^(BOOL r) {
            __strong typeof(weakself) strongSelf = weakself;
            if (r) {
                route.next = nil;
                ThrioModule.pageObservers.lastRoute = route;
                [strongSelf thrio_onNotify:route];
            }
            if (result) {
                result(r);
            }
        }];
    } else {
        [self thrio_onNotify:route];
        if (result) {
            result(YES);
        }
    }
}

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *_Nullable)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result {
    NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
    if (!route) {
        if (result) {
            result(NO);
        }
        return;
    }
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
        NSMutableDictionary *arguments =
        [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithParams:nil]];
        [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
        __weak typeof(self) weakself = self;
        NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
        NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
        NavigatorRouteSendChannel *channel =
        [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId
                                                      withEntrypoint:entrypoint];
        [channel remove:arguments result:^(BOOL r) {
            __strong typeof(weakself) strongSelf = weakself;
            if (r) {
                if (route == strongSelf.thrio_firstRoute) {
                    strongSelf.thrio_firstRoute = route.next;
                    route.prev.next = nil;
                    ThrioModule.pageObservers.lastRoute = route.prev;
                } else if (route == strongSelf.thrio_lastRoute) {
                    route.prev.next = nil;
                    ThrioModule.pageObservers.lastRoute = route.prev;
                    [strongSelf thrio_onNotify:route.prev];
                } else {
                    route.prev.next = route.next;
                    route.next.prev = route.prev;
                }
            }
            if (result) {
                result(r);
            }
        }];
    } else {
        if (route == self.thrio_firstRoute) {
            self.thrio_firstRoute = route.next;
            self.thrio_firstRoute.prev = nil;
        } else if (route == self.thrio_lastRoute) {
            route.prev.next = nil;
            [self thrio_onNotify:route.prev];
        } else {
            route.prev.next = route.next;
            route.next.prev = route.prev;
        }
        if (result) {
            result(YES);
        }
    }
}

- (void)thrio_replaceUrl:(NSString *)url
                   index:(NSNumber *_Nullable)index
                  newUrl:(NSString *)newUrl
                newIndex:(NSNumber *)newIndex
                  result:(ThrioBoolCallback _Nullable)result {
    NavigatorPageRoute *oldRoute = [self thrio_getRouteByUrl:url index:index];
    if (!oldRoute) {
        if (result) {
            result(NO);
        }
        return;
    }
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
        NSDictionary *arguments = [oldRoute.settings toArgumentsWithNewUrl:newUrl newIndex:newIndex];
        NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
        NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
        NavigatorRouteSendChannel *channel =
        [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId
                                                      withEntrypoint:entrypoint];
        [channel replace:arguments result:^(BOOL r) {
            if (r) {
                NavigatorRouteSettings *newSettings = [NavigatorRouteSettings settingsWithUrl:newUrl
                                                                                        index:newIndex
                                                                                       nested:oldRoute.settings.nested
                                                                                       params:nil];
                [[oldRoute initWithSettings:newSettings] removeNotify];
            }
            if (result) {
                result(r);
            }
        }];
    } else {
        if (result) {
            result(NO);
        }
    }
}

- (void)thrio_canPopInRoot:(BOOL)inRoot result:(ThrioBoolCallback _Nullable)result {
    NavigatorPageRoute *lastRoute = [self thrio_lastRoute];
    if (inRoot) {
        NavigatorPageRoute *firstRoute = [self thrio_firstRoute];
        if (lastRoute == firstRoute) {
            if (result) {
                result(NO);
                return;
            }
        }
    }
    NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[lastRoute.settings toArguments]];
    [arguments setObject:[NSNumber numberWithBool:inRoot] forKey:@"inRoot"];
    NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
    NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
    NavigatorRouteSendChannel *channel =
    [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId withEntrypoint:entrypoint];
    [channel canPop:arguments result:result];
}

- (void)thrio_didPushUrl:(NSString *)url index:(NSNumber *)index {
    NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
    if (!route) {
        self.thrio_lastRoute.next = route;
        route.prev = self.thrio_lastRoute;
    }
}

- (void)thrio_didPopUrl:(NSString *)url index:(NSNumber *)index {
    // didPop来自于Dart侧滑关掉的页面，只需要同步route的状态，发出页面通知即可
    NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
    if (route) {
        route.prev.next = nil;
        ThrioModule.pageObservers.lastRoute = route.prev;
        [self thrio_onNotify:route.prev];
    }
}

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index {
    // didPopTo来自于Dart侧直接调用Navigator的行为，只需要同步route的状态，发出页面通知即可
    NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
    if (route) {
        route.next = nil;
        ThrioModule.pageObservers.lastRoute = route;
        [self thrio_onNotify:route];
    }
}

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index {
    // didRemove来自于Dart侧直接调用Navigator的行为，只需要同步route的状态，发出页面通知即可
    NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
    if (route) {
        if (route == self.thrio_firstRoute) {
            self.thrio_firstRoute = route.next;
            self.thrio_firstRoute.prev = nil;
        } else if (route == self.thrio_lastRoute) {
            route.prev.next = nil;
            ThrioModule.pageObservers.lastRoute = route.prev;
            [self thrio_onNotify:route.prev];
        } else {
            route.prev.next = route.next;
            route.next.prev = route.prev;
        }
    }
}

- (NavigatorPageRoute *_Nullable)thrio_getRouteByUrl:(NSString *)url
                                               index:(NSNumber *)index {
    NavigatorPageRoute *last = self.thrio_lastRoute;
    if (url.length < 1) {
        return last;
    }
    do {
        if ([last.settings.url isEqualToString:url] &&
            (index == nil || [index isEqualToNumber:@0] || [last.settings.index isEqualToNumber:index])) {
            return last;
        }
    } while ((last = last.prev));
    return nil;
}

- (NavigatorPageRoute *_Nullable)thrio_getLastRouteByUrl:(NSString *)url {
    NavigatorPageRoute *last = self.thrio_lastRoute;
    if (url.length < 1) {
        return last;
    }
    do {
        if ([last.settings.url isEqualToString:url]) {
            return last;
        }
    } while ((last = last.prev));
    return nil;
}

- (NSArray *)thrio_getAllRoutesByUrl:(NSString *_Nullable)url {
    NSMutableArray *routes = [NSMutableArray array];
    NavigatorPageRoute *first = self.thrio_firstRoute;
    do {
        if (first && (!url || url.length < 1 ||
                      [first.settings.url isEqualToString:url])) {
            [routes addObject:first];
        }
    } while ((first = first.next));
    return [routes copy];
}

#pragma mark - method swizzling

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self instanceSwizzle:@selector(viewWillAppear:)
                  newSelector:@selector(thrio_viewWillAppear:)];
        [self instanceSwizzle:@selector(viewDidAppear:)
                  newSelector:@selector(thrio_viewDidAppear:)];
        [self instanceSwizzle:@selector(viewWillDisappear:)
                  newSelector:@selector(thrio_viewWillDisappear:)];
        [self instanceSwizzle:@selector(viewDidDisappear:)
                  newSelector:@selector(thrio_viewDidDisappear:)];
    });
}

- (void)thrio_viewWillAppear:(BOOL)animated {
    [self thrio_viewWillAppear:animated];
    
    if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
        [ThrioModule.pageObservers willAppear:self.thrio_lastRoute.settings];
    }
}

- (void)thrio_viewDidAppear:(BOOL)animated {
    [self thrio_viewDidAppear:animated];
    
    // 如果侧滑返回的手势放弃，需要清除thrio_popingViewController标记
    if (self.navigationController.thrio_popingViewController == self) {
        self.navigationController.thrio_popingViewController = nil;
    }
    
    if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
        [ThrioModule.pageObservers didAppear:self.thrio_lastRoute.settings];
    }
    
    if (self.thrio_firstRoute &&
        ([self isKindOfClass:NavigatorFlutterViewController.class] ||
         [self conformsToProtocol:@protocol(NavigatorPageNotifyProtocol)])) {
        // 当页面出现后，给页面发送通知
        [self thrio_onNotify:self.thrio_lastRoute];
    }
    
    if (self.thrio_hidesNavigationBar_ && self.thrio_hidesNavigationBar_.boolValue != self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = self.thrio_hidesNavigationBar_.boolValue;
    }
    
    if (![self isKindOfClass:NavigatorFlutterViewController.class] && self.navigationController.navigationBarHidden) {
        [self.navigationController thrio_addPopGesture];
    } else {
        [self.navigationController thrio_removePopGesture];
    }
    
    if (![self isKindOfClass:NavigatorFlutterViewController.class]) {
        if (self.thrio_hidesNavigationBar_ == nil) {
            self.thrio_hidesNavigationBar_ = @(self.navigationController.navigationBarHidden);
        }
        if (self.thrio_willPopBlock) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    } else {
        if (self.thrio_firstRoute == self.thrio_lastRoute) {
            [self.navigationController thrio_addPopGesture];
        } else {
            [self.navigationController thrio_removePopGesture];
        }
    }
}

- (void)thrio_viewWillDisappear:(BOOL)animated {
    [self thrio_viewWillDisappear:animated];
    
    if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
        [ThrioModule.pageObservers willDisappear:self.thrio_lastRoute.settings];
    }
}

- (void)thrio_viewDidDisappear:(BOOL)animated {
    [self thrio_viewDidDisappear:animated];
    [self.navigationController thrio_removePopGesture];
    
    if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
        [ThrioModule.pageObservers didDisappear:self.thrio_lastRoute.settings];
    }
}

- (void)thrio_onNotify:(NavigatorPageRoute *)route {
    NSDictionary *notifies = [route removeNotify];
    for (NSString *name in notifies.allKeys) {
        id params = notifies[name];
        if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
            id serializeParams = [ThrioModule serializeParams:params];
            NSDictionary *arguments = serializeParams ? @{
                @"url": route.settings.url,
                @"index": route.settings.index,
                @"name": name,
                @"params": serializeParams,
            } : @{
                @"url": route.settings.url,
                @"index": route.settings.index,
                @"name": name,
            };
            NSString *entrypoint = [(NavigatorFlutterViewController *)self entrypoint];
            NSUInteger pageId = [(NavigatorFlutterViewController *)self pageId];
            NavigatorRouteSendChannel *channel =
            [NavigatorFlutterEngineFactory.shared getSendChannelByPageId:pageId
                                                          withEntrypoint:entrypoint];
            [channel notify:arguments];
        } else {
            id deserializeParams = [ThrioModule deserializeParams:params];
            if ([self conformsToProtocol:@protocol(NavigatorPageNotifyProtocol)]) {
                [(id<NavigatorPageNotifyProtocol>)self onNotify:name params:deserializeParams];
            }
        }
    }
}

@end

NS_ASSUME_NONNULL_END
