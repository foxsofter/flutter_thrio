//
//  ThrioPopGestureRecognizerDelegate.h
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioPopGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

NS_ASSUME_NONNULL_END
