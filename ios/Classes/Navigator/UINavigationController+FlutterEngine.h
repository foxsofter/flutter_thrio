//
//  UINavigationController+FlutterEngine.h
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import "ThrioFlutterViewController.h"
#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (FlutterEngine)

- (void)thrio_startup;

@property (nonatomic, strong, readonly, nullable) FlutterEngine *thrio_engine;

@property (nonatomic, strong, readonly, nullable) ThrioChannel *thrio_channel;

@property (nonatomic, strong, readonly, nullable) ThrioFlutterViewController *thrio_flutterViewController;

- (void)thrio_attachFlutterViewController:(ThrioFlutterViewController *)viewController;

- (void)thrio_detachFlutterViewController:(ThrioFlutterViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
