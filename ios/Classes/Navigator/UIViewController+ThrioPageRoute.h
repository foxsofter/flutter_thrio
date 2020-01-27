//
//  UIViewController+ThrioPage.h
//  thrio
//
//  Created by foxsofter on 2019/12/16.
//

#import <UIKit/UIKit.h>

#import "ThrioTypes.h"
#import "ThrioPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ThrioPageRoute)

@property (nonatomic, assign) BOOL hidesNavigationBarWhenPushed;

@property (nonatomic, copy, nullable) ThrioWillPopCallback willPopCallback;

@property (nonatomic, strong, readonly, nullable) ThrioPageRoute *firstRoute;

@property (nonatomic, strong, readonly, nullable) ThrioPageRoute *lastRoute;

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

- (ThrioPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url index:(NSNumber *)index;

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url;

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
