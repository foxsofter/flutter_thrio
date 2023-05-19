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
#import "NavigatorFlutterViewController.h"
#import "NavigatorPageObserverChannel.h"
#import "NavigatorRouteObserverChannel.h"
#import "NavigatorRouteReceiveChannel.h"
#import "NavigatorRouteSendChannel.h"
#import "ThrioChannel.h"
#import "ThrioFlutterEngine.h"
#import "FlutterThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterEngine : NSObject

- (instancetype)initWithEntrypoint:(NSString *)entrypoint
                        withEngine:(ThrioFlutterEngine *)flutterEngine NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)startupWithReadyBlock:(ThrioEngineReadyCallback _Nullable)block;

@property (nonatomic, copy, readonly) NSString *entrypoint;

@property (nonatomic, readonly) ThrioFlutterEngine *flutterEngine;

@property (nonatomic, readonly) NavigatorRouteReceiveChannel *receiveChannel;

@property (nonatomic, readonly) NavigatorRouteSendChannel *sendChannel;

@property (nonatomic, readonly) NavigatorPageObserverChannel *pageChannel;

@property (nonatomic, readonly) NavigatorRouteObserverChannel *routeChannel;

@property (nonatomic, readonly) ThrioChannel *moduleContextChannel;

- (void)pushViewController:(NavigatorFlutterViewController *)viewController;

- (NSUInteger)popViewController:(NavigatorFlutterViewController *)viewController;

- (void)destroyContext;

@end

NS_ASSUME_NONNULL_END
