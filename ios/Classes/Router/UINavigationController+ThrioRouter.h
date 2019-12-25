//
//  UINavigationController+Thrio.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <UIKit/UIKit.h>
#import "ThrioNavigationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ThrioRouter)<
  ThrioNavigationProtocol,
  UINavigationControllerDelegate
>

@end

NS_ASSUME_NONNULL_END
