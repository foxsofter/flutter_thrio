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

#import "NSPointerArray+Thrio.h"
#import "NavigatorConsts.h"
#import "NavigatorFlutterEngineFactory.h"
#import "ThrioModule+PageBuilders.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioRegistrySet.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopGesture.h"
#import "UIViewController+Navigator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator

#pragma mark - push methods

+ (void)pushUrl:(NSString *)url {
    [self _pushUrl:url
            params:nil
          animated:YES
    fromEntrypoint:nil
            result:nil
      poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url result:(ThrioNumberCallback)result {
    [self _pushUrl:url
            params:nil
          animated:YES
    fromEntrypoint:nil
            result:result
      poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:nil
          animated:YES
    fromEntrypoint:nil
            result:nil
      poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url params:(id)params {
    [self _pushUrl:url
            params:params
          animated:YES
    fromEntrypoint:nil
            result:nil
      poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
         result:(ThrioNumberCallback)result {
    [self _pushUrl:url
            params:params
          animated:YES
    fromEntrypoint:nil
            result:result
      poppedResult:nil];
}

+ (void) pushUrl:(NSString *)url
          params:(id)params
    poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:params
          animated:YES
    fromEntrypoint:nil
            result:nil
      poppedResult:poppedResult];
}

+ (void) pushUrl:(NSString *)url
          params:(id)params
          result:(ThrioNumberCallback)result
    poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:params
          animated:YES
    fromEntrypoint:nil
            result:result
      poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url animated:(BOOL)animated {
    [self _pushUrl:url
            params:nil
          animated:animated
    fromEntrypoint:nil
            result:nil
      poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioNumberCallback)result {
    [self _pushUrl:url
            params:nil
          animated:animated
    fromEntrypoint:nil
            result:result
      poppedResult:nil];
}

+ (void) pushUrl:(NSString *)url
        animated:(BOOL)animated
    poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:nil
          animated:animated
    fromEntrypoint:nil
            result:nil
      poppedResult:poppedResult];
}

+ (void) pushUrl:(NSString *)url
        animated:(BOOL)animated
          result:(ThrioNumberCallback)result
    poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:nil
          animated:animated
    fromEntrypoint:nil
            result:result
      poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
       animated:(BOOL)animated {
    [self _pushUrl:url
            params:params
          animated:animated
    fromEntrypoint:nil
            result:nil
      poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
       animated:(BOOL)animated
         result:(ThrioNumberCallback)result {
    [self _pushUrl:url
            params:params
          animated:animated
    fromEntrypoint:nil
            result:result
      poppedResult:nil];
}

+ (void) pushUrl:(NSString *)url
          params:(id)params
        animated:(BOOL)animated
    poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:params
          animated:animated
    fromEntrypoint:nil
            result:nil
      poppedResult:poppedResult];
}

+ (void) pushUrl:(NSString *)url
          params:(id)params
        animated:(BOOL)animated
          result:(ThrioNumberCallback)result
    poppedResult:(ThrioIdCallback)poppedResult {
    [self _pushUrl:url
            params:params
          animated:animated
    fromEntrypoint:nil
            result:result
      poppedResult:poppedResult];
}

#pragma mark - notify methods

+ (void)notifyWithName:(NSString *)name {
    [self _notifyUrl:nil index:nil name:name params:nil result:nil];
}

+ (void)notifyWithName:(NSString *)name
                result:(ThrioBoolCallback)result {
    [self _notifyUrl:nil index:nil name:name params:nil result:result];
}

+ (void)notifyWithName:(NSString *)name params:(id)params {
    [self _notifyUrl:nil index:nil name:name params:params result:nil];
}

+ (void)notifyWithName:(NSString *)name
                params:(id)params
                result:(ThrioBoolCallback)result {
    [self _notifyUrl:nil index:nil name:name params:params result:result];
}

+ (void)notifyUrl:(NSString *)url name:(NSString *)name {
    [self _notifyUrl:url index:nil name:name params:nil result:nil];
}

+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           result:(ThrioBoolCallback)result {
    [self _notifyUrl:url index:nil name:name params:nil result:result];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name {
    [self _notifyUrl:url index:index name:name params:nil result:nil];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           result:(ThrioBoolCallback)result {
    [self _notifyUrl:url index:index name:name params:nil result:result];
}

+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(id)params {
    [self _notifyUrl:url index:nil name:name params:params result:nil];
}

+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(id)params
           result:(ThrioBoolCallback)result {
    [self _notifyUrl:url index:nil name:name params:params result:result];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(id)params {
    [self _notifyUrl:url index:index name:name params:params result:nil];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(id)params
           result:(ThrioBoolCallback)result {
    [self _notifyUrl:url index:index name:name params:params result:result];
}

#pragma mark - pop methods

+ (void)pop {
    [self _popParams:nil animated:YES result:nil];
}

+ (void)popParams:(id)params {
    [self _popParams:params animated:YES result:nil];
}

+ (void)popAnimated:(BOOL)animated {
    [self _popParams:nil animated:animated result:nil];
}

+ (void)popParams:(id)params animated:(BOOL)animated {
    [self _popParams:params animated:animated result:nil];
}

+ (void)popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
    [self _popParams:nil animated:animated result:nil];
}

+ (void)popParams:(id)params result:(ThrioBoolCallback)result {
    [self _popParams:params animated:YES result:result];
}

+ (void)popParams:(id)params
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result {
    [self _popParams:params animated:animated result:result];
}

#pragma mark - popFlutter methods

+ (void)popFlutter {
    [self _popFlutterParams:nil animated:YES result:nil];
}

+ (void)popFlutterParams:(id)params {
    [self _popFlutterParams:params animated:YES result:nil];
}

+ (void)popFlutterAnimated:(BOOL)animated {
    [self _popFlutterParams:nil animated:animated result:nil];
}

+ (void)popFlutterParams:(id)params animated:(BOOL)animated {
    [self _popFlutterParams:params animated:animated result:nil];
}

+ (void)popFlutterAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
    [self _popFlutterParams:nil animated:animated result:nil];
}

+ (void)popFlutterParams:(id)params result:(ThrioBoolCallback)result {
    [self _popFlutterParams:params animated:YES result:result];
}

+ (void)popFlutterParams:(id)params
                animated:(BOOL)animated
                  result:(ThrioBoolCallback)result {
    [self _popFlutterParams:params animated:animated result:result];
}

#pragma mark - popTo methods

+ (void)popToUrl:(NSString *)url {
    [self _popToUrl:url index:nil animated:YES result:nil];
}

+ (void)popToUrl:(NSString *)url
          result:(ThrioBoolCallback)result {
    [self _popToUrl:url index:nil animated:YES result:result];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index {
    [self _popToUrl:url index:index animated:YES result:nil];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
          result:(ThrioBoolCallback)result {
    [self _popToUrl:url index:index animated:YES result:result];
}

+ (void)popToUrl:(NSString *)url
        animated:(BOOL)animated {
    [self _popToUrl:url index:nil animated:animated result:nil];
}

+ (void)popToUrl:(NSString *)url
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
    [self _popToUrl:url index:nil animated:animated result:result];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated {
    [self _popToUrl:url index:index animated:animated result:nil];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
    [self _popToUrl:url index:index animated:animated result:result];
}

#pragma mark - remove methods

+ (void)removeUrl:(NSString *)url {
    [self _removeUrl:url index:nil animated:YES result:nil];
}

+ (void)removeUrl:(NSString *)url
           result:(ThrioBoolCallback)result {
    [self _removeUrl:url index:nil animated:YES result:result];
}

+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index {
    [self _removeUrl:url index:index animated:YES result:nil];
}

+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
           result:(ThrioBoolCallback)result {
    [self _removeUrl:url index:index animated:YES result:result];
}

+ (void)removeUrl:(NSString *)url
         animated:(BOOL)animated {
    [self _removeUrl:url index:nil animated:animated result:nil];
}

+ (void)removeUrl:(NSString *)url
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result {
    [self _removeUrl:url index:nil animated:animated result:result];
}

+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated {
    [self _removeUrl:url index:index animated:animated result:nil];
}

+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result {
    [self _removeUrl:url index:index animated:animated result:result];
}

#pragma mark - get index methods

+ (NavigatorPageRoute *_Nullable)lastRoute {
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        NavigatorPageRoute *route = [nvc thrio_lastRoute];
        if (route && ![route.settings.index isEqualToNumber:@0]) {
            return route;
        }
    }
    return nil;
}

+ (NavigatorPageRoute *_Nullable)getLastRouteByUrl:(NSString *)url {
    NavigatorPageRoute *lastRoute = nil;
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        NavigatorPageRoute *route = [nvc thrio_getLastRouteByUrl:url];
        if (route && ![route.settings.index isEqualToNumber:@0]) {
            if (!lastRoute) {
                lastRoute = route;
            } else {
                if (lastRoute.settings.index.integerValue < route.settings.index.integerValue) {
                    lastRoute = route;
                }
            }
        }
    }
    return lastRoute;
}

+ (NSArray *)allRoutes {
    return [self _getAllRoutesByUrl:nil];
}

+ (NSArray *)getAllRoutesByUrl:(NSString *)url {
    return [self _getAllRoutesByUrl:url];
}

+ (BOOL)isInitialRoute:(NSString *)url index:(NSNumber *_Nullable)index {
    NSArray *allNvcs = [self.navigationControllers.allObjects.reverseObjectEnumerator allObjects];
    for (UINavigationController *nvc in allNvcs) {
        NavigatorPageRoute *firstRoute = [nvc.viewControllers.firstObject thrio_firstRoute];
        return firstRoute &&
        [firstRoute.settings.url isEqualToString:url] &&
        (index == nil || index == 0 || [firstRoute.settings.index isEqualToNumber:index]);
    }
    return NO;
}

#pragma mark - engine methods

+ (FlutterEngine *)getEngineByViewContontroller:(NavigatorFlutterViewController *)viewController
                                 withEntrypoint:(NSString *)entrypoint {
    return [NavigatorFlutterEngineFactory.shared getEngineByEntrypoint:entrypoint].flutterEngine;
}

@end

NS_ASSUME_NONNULL_END
