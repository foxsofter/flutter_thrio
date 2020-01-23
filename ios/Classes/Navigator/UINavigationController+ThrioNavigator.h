//
//  UINavigationController+ThrioNavigator.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <UIKit/UIKit.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ThrioNavigator)

- (BOOL)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated;

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber *)index
                   name:(NSString *)name
                 params:(NSDictionary *)params;

- (BOOL)thrio_popUrl:(NSString *)url
               index:(NSNumber *)index
            animated:(BOOL)animated;

- (BOOL)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated;

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
