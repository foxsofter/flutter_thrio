//
//  ThrioNavigationControllerDelegate.h
//  thrio
//
//  Created by Wei ZhongDan on 2020/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigationControllerDelegate : NSObject<UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@property (nonatomic, weak) id<UINavigationControllerDelegate> originDelegate;

@end

NS_ASSUME_NONNULL_END
