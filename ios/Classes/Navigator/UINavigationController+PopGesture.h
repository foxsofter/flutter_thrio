//
//  UINavigationController+PopGesture.h
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import <UIKit/UIKit.h>
#import "ThrioPopGestureRecognizerDelegate.h"
#import "ThrioNavigationControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (PopGesture)

@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *thrio_popGestureRecognizer;

@property (nonatomic, strong, readonly) ThrioPopGestureRecognizerDelegate *thrio_popGestureRecognizerDelegate;

@property (nonatomic, strong, readonly) ThrioNavigationControllerDelegate *thrio_navigationControllerDelegate;

- (void)thrio_addPopGesture;

- (void)thrio_removePopGesture;

@end

NS_ASSUME_NONNULL_END
