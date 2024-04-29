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

#import "NavigatorPageRoute.h"
#import "NavigatorPageObservers.h"
#import "NavigatorRouteObservers.h"
#import "ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator (Internal)

+ (UINavigationController *_Nullable)navigationController;

+ (NSPointerArray *)navigationControllers;

+ (void)  _pushUrl:(NSString *)url
            params:(id _Nullable)params
          animated:(BOOL)animated
    fromEntrypoint:fromEntrypoint
            result:(ThrioNumberCallback _Nullable)result
          fromURL:(NSString *_Nullable)fromURL
           prevURL:(NSString *_Nullable)prevURL
          innerURL:(NSString *_Nullable)innerURL
      poppedResult:(ThrioIdCallback _Nullable)poppedResult;

+ (void)_notifyUrl:(NSString *_Nullable)url
             index:(NSNumber *_Nullable)index
              name:(NSString *)name
            params:(id _Nullable)params
            result:(ThrioBoolCallback _Nullable)result;

+ (void)_maybePopParams:(id _Nullable)params
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result;

+ (void)_popParams:(id _Nullable)params
          animated:(BOOL)animated
            result:(ThrioBoolCallback _Nullable)result;

+ (void)_popFlutterParams:(id _Nullable)params
                 animated:(BOOL)animated
                   result:(ThrioBoolCallback _Nullable)result;

+ (void)_popToUrl:(NSString *)url
            index:(NSNumber *_Nullable)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback _Nullable)result;

+ (void)_removeUrl:(NSString *)url
             index:(NSNumber *_Nullable)index
          animated:(BOOL)animated
            result:(ThrioBoolCallback _Nullable)result;

+ (void)_replaceUrl:(NSString *)url
              index:(NSNumber *_Nullable)index
             newUrl:(NSString *)newUrl
             result:(ThrioNumberCallback _Nullable)result;

+ (void)_canPop:(ThrioBoolCallback _Nullable)result;

+ (NSArray *)_getAllRoutesByUrl:(NSString *_Nullable)url;

+ (void)_setPopDisabledUrl:(NSString *)url
                     index:(NSNumber *)index
                  disabled:(BOOL)disabled;

+ (void)_hotRestart:(ThrioBoolCallback)result;

+ (NavigatorPageRoute *_Nullable)_getLastRouteByEntrypoint:(NSString *)entrypoint;

@end

NS_ASSUME_NONNULL_END
