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

// A function for registering a module, which will call
// the `onModuleRegister` function of the `module`.
//
- (void)registerModule:(id<ThrioModuleProtocol>)module;

// A function for module initialization that will call
// the `onPageRegister`, `onModuleInit` and `onModuleAsyncInit`
// methods of all modules.
//
- (void)initModule;

// Register native view controller builder for url.
//
- (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                  forUrl:(NSString *)url;

// Sets the `ThrioFlutterViewController` builder.
//
// Need to be register when extending the `ThrioFlutterViewController` class.
//
- (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder;

@optional

// A function for registering submodules.
//
- (void)onModuleRegister;

// A function for registering a page builder.
//
- (void)onPageRegister;

// A function for module initialization.
//
- (void)onModuleInit;

// A function for module asynchronous initialization.
//
- (void)onModuleAsyncInit;

@end

NS_ASSUME_NONNULL_END
