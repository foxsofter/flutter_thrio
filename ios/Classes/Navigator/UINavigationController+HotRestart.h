//
//  UINavigationController+HotRestart.h
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import <UIKit/UIKit.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (HotRestart)

- (void)thrio_hotRestart:(ThrioBoolCallback)result;

@end

NS_ASSUME_NONNULL_END
