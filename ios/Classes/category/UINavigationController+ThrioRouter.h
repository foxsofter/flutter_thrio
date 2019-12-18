//
//  UINavigationController+ThrioRouter.h
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/17.
//

#import <UIKit/UIKit.h>
#import "ThrioRouterPageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ThrioRouter)<
  ThrioRouterPageProtocol,
  UINavigationControllerDelegate
>

@end

NS_ASSUME_NONNULL_END
