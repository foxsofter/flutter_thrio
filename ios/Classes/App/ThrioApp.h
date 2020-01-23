//
//  ThrioApp.h
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "ThrioFlutterViewController.h"
#import "ThrioNavigatorProtocol.h"
#import "ThrioChannel.h"
#import "ThrioModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioApp : ThrioModule<ThrioNavigatorProtocol>

+ (instancetype)shared;

@property (nonatomic, strong, readonly) ThrioChannel *channel;

// Gets the flutter engin.
//
@property (nonatomic, strong, readonly) FlutterEngine *engine;

// Always return to the topmost UIViewController of UINavigationController.
//
@property (nonatomic, strong, readonly) UIViewController *topmostViewController;

// Gets the `FlutterViewController` for flutter engine.
//
@property (nonatomic, strong, readonly) ThrioFlutterViewController *flutterViewController;

// Sets the `FlutterViewController` for flutter engine.
//
- (void)attachFlutterViewController:(ThrioFlutterViewController *)page;

// Sets the `FlutterViewController` of flutter engine to a empty view controller.
//
- (void)detachFlutterViewController;

// Register native view controller builder for url.
//
- (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                  forUrl:(NSString *)url;

// Sets the `ThrioFlutterViewController` builder.
//
// Need to be register when extending the `ThrioFlutterPage` class.
//
- (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder;

@end

NS_ASSUME_NONNULL_END
