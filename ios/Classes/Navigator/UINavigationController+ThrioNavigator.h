//
//  UINavigationController+ThrioNavigator.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <UIKit/UIKit.h>
#import "ThrioTypes.h"
#import "ThrioPopGestureRecognizerDelegate.h"
#import "ThrioNavigationControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ThrioNavigator)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *thrio_popGestureRecognizer;
@property (nonatomic, strong, readonly) ThrioPopGestureRecognizerDelegate *thrio_popGestureRecognizerDelegate;

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated
               result:(ThrioBoolCallback)result;

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber *)index
                   name:(NSString *)name
                 params:(NSDictionary *)params;

- (void)thrio_popAnimated:(BOOL)animated
                   result:(ThrioBoolCallback)result;

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback)result;

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback)result;

- (NSNumber *)thrio_lastIndex;

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url;

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url;

- (BOOL)thrio_ContainsUrl:(NSString *)url;

- (BOOL)thrio_ContainsUrl:(NSString *)url index:(NSNumber *)index;

- (ThrioVoidCallback)thrio_registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                        forUrl:(NSString *)url;

- (ThrioVoidCallback)thrio_registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder;

@end

NS_ASSUME_NONNULL_END
