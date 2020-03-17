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

#import "NavigatorPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

/// An interface for observing the page lifecycle of a [ThrioNavigator].
///
@protocol NavigatorPageObserverProtocol <NSObject>

@optional
/// The [ThrioNavigator] created `route`.
///
- (void)onCreate:(NavigatorRouteSettings *)routeSettings;

/// The `route` is about to be activated.
///
- (void)willAppear:(NavigatorRouteSettings *)routeSettings;

/// The `route` has been activated.
///
- (void)didAppear:(NavigatorRouteSettings *)routeSettings;

/// The `route` is about to disappear.
///
- (void)willDisappear:(NavigatorRouteSettings *)routeSettings;

/// The `route` is has disappeared.
///
- (void)didDisappear:(NavigatorRouteSettings *)routeSettings;

@end

NS_ASSUME_NONNULL_END
