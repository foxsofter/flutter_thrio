//
//  ThrioApp.h
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "ThrioFlutterPage.h"
#import "ThrioRouteProtocol.h"
#import "ThrioChannel.h"
#import "ThrioModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioApp : ThrioModule<ThrioRouteProtocol>

+ (instancetype)shared;

@property (nonatomic, strong, readonly) ThrioChannel *channel;

// Gets the flutter engin.
//
@property (nonatomic, strong, readonly) FlutterEngine *engine;

// Always return to the topmost UIViewController of UINavigationController.
//
@property (nonatomic, strong, readonly) UIViewController *topmostPage;

// Gets the `FlutterViewController` for flutter engine.
//
@property (nonatomic, strong, readonly) ThrioFlutterPage *flutterPage;

// Sets the `FlutterViewController` for flutter engine.
//
- (void)attachFlutterPage:(ThrioFlutterPage *)page;

// Sets the `FlutterViewController` of flutter engine to a empty page.
//
- (void)detachFlutterPage;

// Register native page builder for url.
//
- (ThrioVoidCallback)registerNativePageBuilder:(ThrioNativePageBuilder)builder
                                        forUrl:(NSString *)url;

// Sets the `ThrioFlutterPage` builder.
//
// Need to be register when extending the `ThrioFlutterPage` class.
//
- (void)registerFlutterPageBuilder:(ThrioFlutterPageBuilder)builder;

// Get the topmost page index with `url`.
//
- (NSNumber *)topmostPageIndexWithUrl:(NSString *)url;


@end

NS_ASSUME_NONNULL_END
