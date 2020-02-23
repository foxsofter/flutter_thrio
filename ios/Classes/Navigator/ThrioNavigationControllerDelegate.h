//
//  ThrioNavigationControllerDelegate.h
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigationControllerDelegate : NSObject<UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

/// 原来的UINavigationControllerDelegate
///
@property (nonatomic, weak) id<UINavigationControllerDelegate> originDelegate;

@end

NS_ASSUME_NONNULL_END
