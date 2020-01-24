//
//  ThrioModuleProtocol.h
//  thrio
//
//  Created by Wei ZhongDan on 2019/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioModuleProtocol <NSObject>

@required

// A function for module initialization that will call
// the `onPageRegister`, `onSyncInit` and `onAsyncInit`
// methods of all modules.
//
+ (void)init;

// A function for registering a module, which will call
// the `onModuleRegister` function of the `module`.
//
+ (void)register:(id<ThrioModuleProtocol>)module;

@optional

// A function for registering submodules.
//
- (void)onModuleRegister;

// A function for registering a page builder.
//
- (void)onPageRegister;

// A function for module initialization.
//
- (void)onSyncInit;

// A function for module asynchronous initialization.
//
- (void)onAsyncInit;

@end

NS_ASSUME_NONNULL_END
