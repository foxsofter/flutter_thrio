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

#import "UIViewController+Navigator.h"
#import "ThrioRegistrySet.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopGesture.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+PageBuilders.h"
#import "ThrioNavigator+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator

#pragma mark - push methods

+ (void)pushUrl:(NSString *)url {
  [self _pushUrl:url params:nil animated:YES result:nil poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url result:(ThrioNumberCallback)result {
  [self _pushUrl:url params:nil animated:YES result:result poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:nil animated:YES result:nil poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url params:(id)params {
  [self _pushUrl:url params:params animated:YES result:nil poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
         result:(ThrioNumberCallback)result {
  [self _pushUrl:url params:params animated:YES result:result poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
   poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:params animated:YES result:nil poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
         result:(ThrioNumberCallback)result
   poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:params animated:YES result:result poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url animated:(BOOL)animated {
  [self _pushUrl:url params:nil animated:animated result:nil poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioNumberCallback)result {
  [self _pushUrl:url params:nil animated:animated result:result poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
   poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:nil animated:animated result:nil poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioNumberCallback)result
   poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:nil animated:animated result:result poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
       animated:(BOOL)animated {
  [self _pushUrl:url params:params animated:animated result:nil poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
       animated:(BOOL)animated
         result:(ThrioNumberCallback)result {
  [self _pushUrl:url params:params animated:animated result:result poppedResult:nil];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
       animated:(BOOL)animated
   poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:params animated:animated result:nil poppedResult:poppedResult];
}

+ (void)pushUrl:(NSString *)url
         params:(id)params
       animated:(BOOL)animated
         result:(ThrioNumberCallback)result
   poppedResult:(ThrioIdCallback)poppedResult {
  [self _pushUrl:url params:params animated:animated result:result poppedResult:poppedResult];
}

+ (void)_pushUrl:(NSString *)url
         params:(id _Nullable)params
       animated:(BOOL)animated
         result:(ThrioNumberCallback _Nullable)result
   poppedResult:(ThrioIdCallback _Nullable)poppedResult {
  [self.navigationController thrio_pushUrl:url
                                    params:params
                                  animated:animated
                            fromEntrypoint:nil
                                    result:^(NSNumber *idx) {
    if (result) {
      result(idx);
    }
  } poppedResult:poppedResult];
}

#pragma mark - notify methods

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

+ (void)_notifyUrl:(NSString *)url
            index:(NSNumber * _Nullable)index
             name:(NSString *)name
           params:(id _Nullable)params
           result:(ThrioBoolCallback _Nullable)result {
  BOOL canNotify = [self.navigationController thrio_notifyUrl:url
                                                        index:index
                                                         name:name
                                                       params:params];
  if (result) {
    result(canNotify);
  }
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

+ (void)_popParams:(id _Nullable)params
          animated:(BOOL)animated
            result:(ThrioBoolCallback _Nullable)result {
  [self.navigationController thrio_popParams:params
                                    animated:animated
                                      result:result];
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

+ (void)_popToUrl:(NSString *)url
           index:(NSNumber * _Nullable)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback _Nullable)result {
  [self.navigationController thrio_popToUrl:url
                                      index:index
                                   animated:animated
                                     result:result];
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

+ (void)_removeUrl:(NSString *)url
            index:(NSNumber * _Nullable)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback _Nullable)result {
  [self.navigationController thrio_removeUrl:url
                                       index:index
                                    animated:animated
                                      result:result];
}

#pragma mark - get index methods

+ (NSNumber * _Nullable)lastIndex {
  return [self.navigationController thrio_lastIndex];
}

+ (NSNumber * _Nullable)getLastIndexByUrl:(NSString *)url {
  return [self.navigationController thrio_getLastIndexByUrl:url];
}

+ (NSArray *)getAllIndexByUrl:(NSString *)url {
  return [self.navigationController thrio_getAllIndexByUrl:url];
}

#pragma mark - multi-engine methods

static BOOL multiEngineEnabled = NO;

+ (void)setMultiEngineEnabled:(BOOL)enabled {
  multiEngineEnabled = enabled;
}

+ (BOOL)isMultiEngineEnabled {
  return multiEngineEnabled;
}

static NSUInteger engineKeepAliveUrlCount = 10;

+ (void)setMultiEngineKeepAliveUrlCount:(NSUInteger)count {
  engineKeepAliveUrlCount = count;
}

+ (NSUInteger)multiEngineKeepAliveUrlCount {
  return engineKeepAliveUrlCount;
}

@end

NS_ASSUME_NONNULL_END
