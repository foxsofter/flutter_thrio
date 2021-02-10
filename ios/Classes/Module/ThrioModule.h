// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"
#import "ThrioModuleContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioModule : NSObject

@property (nonatomic, readonly) ThrioModuleContext *moduleContext;

/// A function for module initialization that will call  the `onPageBuilderRegister:`, `onModuleInit:`
/// and `onModuleAsyncInit:` methods of all modules.
///
/// Should only be called once when the app startups.
///
+ (void)init:(ThrioModule *)rootModule;

+ (void)init:(ThrioModule *)rootModule multiEngineEnabled:(BOOL)enabled;

/// A function for registering a module.
///
/// Should be called in `onModuleRegister:`.
///
- (void)registerModule:(ThrioModule *)module
     withModuleContext:(ThrioModuleContext *)moduleContext;

/// A function for registering submodules.
///
- (void)onModuleRegister:(ThrioModuleContext *)moduleContext;

/// A function for module initialization.
///
- (void)onModuleInit:(ThrioModuleContext *)moduleContext;

/// A function for module asynchronous initialization.
///
- (void)onModuleAsyncInit:(ThrioModuleContext *)moduleContext;

/// Startup the flutter engine with `entrypoint`.
///
/// Should be called in `onModuleAsyncInit:`. Subsequent calls will return immediately if the entrypoint is the same.
///
/// Do not override this method.
///
- (void)startupFlutterEngineWithEntrypoint:(NSString *)entrypoint;

@end

NS_ASSUME_NONNULL_END
