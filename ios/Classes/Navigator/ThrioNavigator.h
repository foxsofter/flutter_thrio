//
//  ThrioNavigator.h
//  ThrioNavigator
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ThrioNavigatorProtocol.h"
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator : NSObject<ThrioNavigatorProtocol>

+ (instancetype)shared;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - push methods

- (void)pushUrl:(NSString *)url;

- (void)pushUrl:(NSString *)url
         result:(ThrioBoolCallback)result;

- (void)pushUrl:(NSString *)url
       animated:(BOOL)animated;

- (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result;

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params;

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
         result:(ThrioBoolCallback)result;

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated;

#pragma mark - notify methods

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name;

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           result:(ThrioBoolCallback)result;

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name;

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           result:(ThrioBoolCallback)result;

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params;

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result;

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params;

#pragma mark - pop methods

- (void)pop;

- (void)popAnimated:(BOOL)animated;

#pragma mark - popTo methods

- (void)popToUrl:(NSString *)url;

- (void)popToUrl:(NSString *)url
          result:(ThrioBoolCallback)result;

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index;

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
          result:(ThrioBoolCallback)result;

- (void)popToUrl:(NSString *)url
        animated:(BOOL)animated;

- (void)popToUrl:(NSString *)url
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result;

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated;

#pragma mark - remove methods

- (void)removeUrl:(NSString *)url;

- (void)removeUrl:(NSString *)url
           result:(ThrioBoolCallback)result;

- (void)removeUrl:(NSString *)url
            index:(NSNumber *)index;

- (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
           result:(ThrioBoolCallback)result;

- (void)removeUrl:(NSString *)url
         animated:(BOOL)animated;

- (void)removeUrl:(NSString *)url
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result;

- (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated;

#pragma mark - predicate methods

- (BOOL)canPushUrl:(NSString *)url params:(NSDictionary * _Nullable)params;

- (BOOL)canNotifyUrl:(NSString *)url index:(NSNumber * _Nullable)index;

- (BOOL)canPop;

- (BOOL)canPopToUrl:(NSString *)url index:(NSNumber * _Nullable)index;

- (BOOL)canRemoveUrl:(NSString *)url index:(NSNumber * _Nullable)index;

#pragma mark - get index methods

- (NSNumber *)lastIndex;

- (NSNumber *)getLastIndexByUrl:(NSString *)url;

- (NSArray *)getAllIndexByUrl:(NSString *)url;

#pragma mark - set pop disabled methods

- (void)setPopDisabled:(BOOL)disabled;

- (void)setPopDisabledUrl:(NSString *)url disabled:(BOOL)disabled;

@end

NS_ASSUME_NONNULL_END
