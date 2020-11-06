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
#import <Flutter/Flutter.h>

#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

/// A wrapper class for FlutterMethodChannel and FlutterEventChannel.
///
@interface ThrioChannel : NSObject <FlutterStreamHandler>

/// Construct the instance with a default channel name.
///
+ (instancetype)channelWithEntrypoint:(NSString *)entrypoint;

/// Construct the instance with a `channelName`.
///
+ (instancetype)channelWithEntrypoint:(NSString *)entrypoint
                                 name:(NSString *)channelName;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSString *entrypoint;

/// Invokes the specified Flutter method, expecting no results.
///
- (void)invokeMethod:(NSString *)method;

/// Invokes the specified Flutter method, expecting an asynchronous result.
///
- (void)invokeMethod:(NSString *)method result:(ThrioIdCallback)callback;

/// Invokes the specified Flutter method with the specified arguments, expecting
/// no results.
- (void)invokeMethod:(NSString *)method arguments:(NSDictionary *)arguments;

/// Invokes the specified Flutter method with the specified arguments, expecting
/// an asynchronous result.
///
- (void)invokeMethod:(NSString *)method
           arguments:(NSDictionary *)arguments
              result:(ThrioIdCallback)callback;

/// Register a handler for the specified Flutter method with the specified
/// method.
///
- (ThrioVoidCallback)registryMethod:(NSString *)method
                            handler:(ThrioMethodHandler)handler;

/// Must be called before `invokeMethod` to setup the method channel.
///
- (void)setupMethodChannel:(NSObject<FlutterBinaryMessenger> *)messenger;

/// Sends the specified Flutter event with the specified name and arguments.
///
- (void)sendEvent:(NSString *)name arguments:(id _Nullable)arguments;

/// Register a handler for the specified Flutter event with the specified
/// name.
///
- (ThrioVoidCallback)registryEvent:(NSString *)name
                           handler:(ThrioEventHandler)handler;

/// Must be called before `sendEvent` to setup the event channel.
///
- (void)setupEventChannel:(NSObject<FlutterBinaryMessenger> *)messenger;

@end

NS_ASSUME_NONNULL_END
