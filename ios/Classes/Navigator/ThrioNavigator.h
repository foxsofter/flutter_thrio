//
//  ThrioNavigator.h
//  ThrioNavigator
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ThrioTypes.h"
#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator : NSObject

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - push methods

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
         result:(ThrioBoolCallback)result;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
         result:(ThrioBoolCallback)result;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated;

/// Push the page onto the navigation stack.
///
/// If a native page builder exists for the url, open the native page,
/// otherwise open the flutter page.
///
+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result;

#pragma mark - notify methods

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           result:(ThrioBoolCallback)result;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           result:(ThrioBoolCallback)result;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params;

/// Send a notification to the page.
///
/// Notifications will be triggered when the page enters the foreground.
/// Notifications with the same name will be overwritten.
///
+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result;

#pragma mark - pop methods

/// Pop a page from the navigation stack.
///
+ (void)pop;

/// Pop a page from the navigation stack.
///
+ (void)popAnimated:(BOOL)animated;

/// Pop a page from the navigation stack.
///
+ (void)popAnimated:(BOOL)animated result:(ThrioBoolCallback)result;

#pragma mark - popTo methods

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
          result:(ThrioBoolCallback)result;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
          result:(ThrioBoolCallback)result;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
        animated:(BOOL)animated;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated;

/// Pop the page in the navigation stack until the page with `url`.
///
+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result;

#pragma mark - remove methods

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
           result:(ThrioBoolCallback)result;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
           result:(ThrioBoolCallback)result;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
         animated:(BOOL)animated;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated;

/// Remove the page with `url` in the navigation stack.
///
+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result;

#pragma mark - predicate methods

/// Returns whether the page can be pushed.
///
+ (BOOL)canPushUrl:(NSString *)url params:(NSDictionary * _Nullable)params;

/// Returns whether the page can be notified.
///
+ (BOOL)canNotifyUrl:(NSString *)url index:(NSNumber * _Nullable)index;

/// Returns whether the navigation stack can be poped.
///
+ (BOOL)canPop;

/// Returns whether the page can be poped to.
///
+ (BOOL)canPopToUrl:(NSString *)url index:(NSNumber * _Nullable)index;

/// Returns whether the page can be removed.
///
+ (BOOL)canRemoveUrl:(NSString *)url index:(NSNumber * _Nullable)index;

#pragma mark - get index methods

/// Returns the index of the page that was last pushed to the navigation
/// stack.
///
+ (NSNumber *)lastIndex;

/// Returns the index of the page that was last pushed to the navigation
/// stack.
///
+ (NSNumber *)getLastIndexByUrl:(NSString *)url;

/// Returns all index of the page with `url` in the navigation stack.
///
+ (NSArray *)getAllIndexByUrl:(NSString *)url;

#pragma mark - set pop disabled methods

/// Setting the last page to disable pop.
///
+ (void)setPopDisabled:(BOOL)disabled;

/// Setting the page with `url` to disable pop.
///
+ (void)setPopDisabledUrl:(NSString *)url
                 disabled:(BOOL)disabled;

/// Setting the page with `url` and `index` to disable pop.
///
+ (void)setPopDisabledUrl:(NSString *)url
                    index:(NSNumber *)index
                 disabled:(BOOL)disabled;

#pragma mark - multi-engine methods

/// Set multi-engine mode to `enabled`, default is NO.
///
/// Should be called before the engine is initialized.
///
+ (void)setMultiEngineEnabled:(BOOL)enabled;

/// Get multi-engine mode enabled or not.
///
+ (BOOL)isMultiEngineEnabled;

/// Set the number of urls that the engine keeps alive in multi-engine mode.
///
/// The default value of `count` is 10.
/// If `count` set to 0, no engines are kept alive.
/// Should be called before the engine is initialized.
///
+ (void)setMultiEngineKeepAliveUrlCount:(NSUInteger)count;

/// Get the number of urls that the engine keeps alive in multi-engine mode.
///
+ (NSUInteger)multiEngineKeepAliveUrlCount;

@end

NS_ASSUME_NONNULL_END
