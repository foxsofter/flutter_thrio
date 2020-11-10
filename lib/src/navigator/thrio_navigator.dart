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

import 'package:flutter/material.dart';

import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

abstract class ThrioNavigator {
  /// Push the page onto the navigation stack.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<int> push({
    @required String url,
    params,
    bool animated = true,
    NavigatorParamsCallback poppedResult,
  }) =>
      ThrioNavigatorImplement.push(
        url: url,
        params: params,
        animated: animated,
        poppedResult: poppedResult,
      );

  /// Send a notification to the page.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notify({
    @required String url,
    int index,
    @required String name,
    params,
  }) =>
      ThrioNavigatorImplement.notify(
        url: url,
        index: index,
        name: name,
        params: params,
      );

  /// Pop a page from the navigation stack.
  ///
  static Future<bool> pop({params, bool animated = true}) =>
      ThrioNavigatorImplement.pop(params: params, animated: animated);

  /// Pop the page in the navigation stack until the page with `url`.
  ///
  static Future<bool> popTo({
    @required String url,
    int index,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.popTo(
        url: url,
        index: index,
        animated: animated,
      );

  /// Remove the page with `url` in the navigation stack.
  ///
  static Future<bool> remove({
    @required String url,
    int index,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.remove(
        url: url,
        index: index,
        animated: animated,
      );

  /// Returns the index of the page that was last pushed to the navigation
  /// stack.
  ///
  static Future<int> lastIndex({String url}) =>
      ThrioNavigatorImplement.lastIndex(url: url);

  /// Returns all index of the page with `url` in the navigation stack.
  ///
  static Future<List<int>> allIndexs({@required String url}) =>
      ThrioNavigatorImplement.allIndexs(url: url);
}
