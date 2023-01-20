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
#import "NavigatorRouteSettings.h"
#import "FlutterThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NavigatorRouteType) {
    NavigatorRouteTypeNone,
    NavigatorRouteTypePush,
    NavigatorRouteTypePushing,
    NavigatorRouteTypePop,
    NavigatorRouteTypePopping,
    NavigatorRouteTypePopTo,
    NavigatorRouteTypePoppingTo,
    NavigatorRouteTypeRemove,
    NavigatorRouteTypeRemoving,
    NavigatorRouteTypeReplace,
    NavigatorRouteTypeReplacing
};

@interface NavigatorPageRoute : NSObject

+ (instancetype)routeWithSettings:(NavigatorRouteSettings *)settings;

- (instancetype)initWithSettings:(NavigatorRouteSettings *)settings;

- (instancetype)init NS_UNAVAILABLE;

- (void)addNotify:(NSString *)name params:(id _Nullable)params;

- (NSDictionary *)removeNotify;

@property (nonatomic, nullable) NavigatorPageRoute *prev;

@property (nonatomic, nullable) NavigatorPageRoute *next;

@property (nonatomic, readonly) NavigatorRouteSettings *settings;

@property (nonatomic, copy, readonly) NSDictionary *notifications;

/// The poppedResult passed in when the push method is called.
///
@property (nonatomic, copy, nullable) ThrioIdCallback poppedResult;

/// The current route was pushed by the engine with `fromEntrypoint`.
///
@property (nonatomic, copy, nullable) NSString *fromEntrypoint;

/// The current route was pushed by the engine with `fromPageId`.
///
@property (nonatomic, assign) NSUInteger fromPageId;

@end

NS_ASSUME_NONNULL_END
