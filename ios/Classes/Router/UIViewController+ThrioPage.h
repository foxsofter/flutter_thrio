//
//  UIViewController+ThrioPage.h
//  thrio
//
//  Created by foxsofter on 2019/12/16.
//

#import <UIKit/UIKit.h>

#import "ThrioPageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ThrioPage)<ThrioPageProtocol>

- (NSDictionary *)pageArguments;

@end

NS_ASSUME_NONNULL_END
