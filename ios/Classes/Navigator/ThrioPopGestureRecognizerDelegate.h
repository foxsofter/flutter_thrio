//
//  ThrioPopGestureRecognizerDelegate.h
//  thrio
//
//  Created by Wei ZhongDan on 2020/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioPopGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

NS_ASSUME_NONNULL_END
