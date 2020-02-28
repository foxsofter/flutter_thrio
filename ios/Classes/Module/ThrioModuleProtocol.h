//
//  ThrioModuleProtocol.h
//  thrio
//
//  Created by foxsofter on 2019/12/20.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioModuleProtocol <NSObject>

@required

/// A function for registering a module.
///
/// Should be called in `onModuleRegister`.
///
- (void)registerModule:(id<ThrioModuleProtocol>)module;

/// A function for module initialization that will call  the `onPageRegister`, `onModuleInit` and `onModuleAsyncInit`
/// methods of all modules.
///
/// Should only be called once when the app startups.
///
- (void)initModule;

/// Register native view controller builder for url.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                  forUrl:(NSString *)url;

/// Sets the `ThrioFlutterViewController` builder.
///
/// Need to be register when extending the `ThrioFlutterViewController` class.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder;

/// Startup the flutter engine with `entrypoint`.
///
/// Should be called in `onModuleAsyncInit`. Subsequent calls will return immediately if the entrypoint is the same.
///
/// Do not override this method.
///
- (void)startupFlutterEngineWithEntrypoint:(NSString *)entrypoint;

@optional

/// A function for registering submodules.
///
- (void)onModuleRegister;

/// A function for registering page builders.
///
- (void)onPageRegister;

/// A function for module initialization.
///
- (void)onModuleInit;

/// A function for module asynchronous initialization.
///
- (void)onModuleAsyncInit;

@end

NS_ASSUME_NONNULL_END
