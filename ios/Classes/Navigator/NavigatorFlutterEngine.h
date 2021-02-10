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
#import "NavigatorFlutterViewController.h"
#import "NavigatorRouteReceiveChannel.h"
#import "NavigatorRouteSendChannel.h"
#import "NavigatorPageObserverChannel.h"
#import "NavigatorRouteObserverChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterEngine : NSObject

- (void)startupWithEntrypoint:(NSString *)entrypoint
                   readyBlock:(ThrioIdCallback _Nullable)block;

@property (nonatomic, readonly, nullable) FlutterEngine *engine;

@property (nonatomic, readonly, nullable) NavigatorRouteReceiveChannel *receiveChannel;

@property (nonatomic, readonly, nullable) NavigatorRouteSendChannel *sendChannel;

@property (nonatomic, readonly, nullable) NavigatorPageObserverChannel *pageChannel;

@property (nonatomic, readonly, nullable) NavigatorRouteObserverChannel *routeChannel;

@property (nonatomic, strong, readonly, nullable) ThrioChannel *moduleContextChannel;

- (void)pushViewController:(NavigatorFlutterViewController *)viewController;

/// 返回当前引擎上剩余的NavigatorFlutterViewController个数
///
- (NSUInteger)popViewController:(NavigatorFlutterViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
