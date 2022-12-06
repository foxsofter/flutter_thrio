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

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

abstract class ThrioNavigator {
  /// Push the page onto the navigation stack.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams> push<TParams, TPopParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared().push<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );

  /// Push the page onto the navigation stack, and remove all old page.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams> pushSingle<TParams, TPopParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared().pushSingle<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );

  /// Push the page onto the navigation stack, and remove the top page.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams> pushReplace<TParams, TPopParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared().pushReplace<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );

  /// Send a notification to the page.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notify<TParams>({
    final String? url,
    final int index = 0,
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notify<TParams>(
        url: url,
        index: index,
        name: name,
        params: params,
      );

  /// Pop a page from the navigation stack.
  ///
  static Future<bool> pop<TParams>({
    final TParams? params,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().pop<TParams>(
        params: params,
        animated: animated,
      );

  /// Pop the page in the navigation stack until the page with `url`.
  ///
  static Future<bool> popTo({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().popTo(
        url: url,
        index: index,
        animated: animated,
      );

  /// Remove the page with `url` in the navigation stack.
  ///
  static Future<bool> remove({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().remove(
        url: url,
        index: index,
        animated: animated,
      );

  /// Remove all pages with `url` in the navigation stack, except the one with index equals to `excludeIndex`.
  ///
  static Future<int> removeAll({required final String url, final int excludeIndex = 0}) =>
      ThrioNavigatorImplement.shared().removeAll(url: url, excludeIndex: excludeIndex);

  /// Replace the flutter page with `newUrl` in the navigation stack.
  ///
  /// Both `url` and `newUrl` must be flutter page.
  ///
  static Future<int> replace({
    required final String url,
    final int index = 0,
    required final String newUrl,
  }) =>
      ThrioNavigatorImplement.shared().replace(
        url: url,
        index: index,
        newUrl: newUrl,
      );

  /// Whether the navigator can be popped.
  ///
  static Future<bool> canPop() => ThrioNavigatorImplement.shared().canPop();

  /// Build widget with `url` and `params`.
  ///
  static Widget? build<TParams>({required final String url, final TParams? params}) =>
      ThrioNavigatorImplement.shared().build(url: url, params: params);

  /// Returns the route of the page that was last pushed to the navigation
  /// stack.
  ///
  static Future<RouteSettings?> lastRoute({final String? url}) =>
      ThrioNavigatorImplement.shared().lastRoute(url: url);

  /// Returns all route of the page with `url` in the navigation stack.
  ///
  static Future<List<RouteSettings>> allRoutes({final String? url}) =>
      ThrioNavigatorImplement.shared().allRoutes(url: url);

  /// Returns the flutter route of the page that was last pushed to the
  /// navigation stack.
  ///
  static RouteSettings? lastFlutterRoute({final String? url}) =>
      ThrioNavigatorImplement.shared().lastFlutterRoute(url: url);

  /// Returns all flutter route of the page with `url` in the navigation stack.
  ///
  static List<RouteSettings> allFlutterRoutes({final String? url}) =>
      ThrioNavigatorImplement.shared().allFlutterRoutes(url: url);

  /// Returns true if there is a route pushed by the Navigator
  /// on the last matching url.
  static bool isContainsInnerRoute({required final String url}) =>
      ThrioNavigatorImplement.shared().isContainsInnerRoute(url: url);
}
