// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter.
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

import 'package:flutter/widgets.dart';

import 'thrio_navigator.dart';

/// An interface for handling the `push` and `pop` behavior of a [ThrioNavigator].
///
mixin NavigatorRouteHandler {
  /// The [ThrioNavigator] pushed `route`.
  ///
  /// returns `null` if the `push` method is not implements.
  ///
  /// returns `true` if the `push` method should not continue executing, otherwise `false`
  /// should abort executing.
  ///
  Future<bool?> onPush(final RouteSettings routeSettings, {final bool animated = true}) async =>
      null;

  /// The [ThrioNavigator] popped `route`.
  ///
  /// returns `null` if the `pop` method is not implements.
  ///
  /// returns `true` if the `pop` method should not continue executing, otherwise `false`
  /// should abort executing.
  ///
  Future<bool?> onPop(final RouteSettings routeSettings, {final bool animated = true}) async =>
      null;
}
