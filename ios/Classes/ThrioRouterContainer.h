//
//  ThrioRouterContainer.h
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import <Flutter/Flutter.h>

#import "ThrioRouterContainerProtocol.h"
#import "Category/UIViewController+ThrioRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRouterContainer : FlutterViewController<ThrioRouterContainerProtocol>

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
