//
//  UIViewController+ThrioPage.h
//  thrio
//
//  Created by foxsofter on 2019/12/16.
//

#import <UIKit/UIKit.h>

#import "ThrioPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ThrioPageRoute)

@property (nonatomic, assign) BOOL hidesNavigationBarWhenPushed;

@property (nonatomic, strong, readonly, nullable) ThrioPageRoute *firstRoute;

@property (nonatomic, strong, readonly, nullable) ThrioPageRoute *lastRoute;

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated;

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber *)index
                   name:(NSString *)name
                 params:(NSDictionary *)params;

- (BOOL)thrio_popAnimated:(BOOL)animated;

- (BOOL)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated;

- (BOOL)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *)index
               animated:(BOOL)animated;

- (ThrioPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url index:(NSNumber *)index;

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url;

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
