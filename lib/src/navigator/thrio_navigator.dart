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

import 'dart:async';

import 'package:flutter/material.dart';

import 'navigator_route.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

abstract class ThrioNavigator {
  /// Push the page onto the navigation stack.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> push<TParams, TPopParams>({
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
  static Future<TPopParams?> pushSingle<TParams, TPopParams>({
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
  static Future<TPopParams?> pushReplace<TParams, TPopParams>({
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

  /// Push the page onto the navigation stack, and remove until the last page with `toUrl`.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveTo<TParams, TPopParams>({
    required final String url,
    required final String toUrl,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared().pushAndRemoveTo<TParams, TPopParams>(
        url: url,
        toUrl: toUrl,
        params: params,
        animated: animated,
        result: result,
      );

  /// Push the page onto the navigation stack, and remove until the first page with `toUrl`.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveToFirst<TParams, TPopParams>({
    required final String url,
    required final String toUrl,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared()
          .pushAndRemoveToFirst<TParams, TPopParams>(
        url: url,
        toUrl: toUrl,
        params: params,
        animated: animated,
        result: result,
      );

  /// Push the page onto the navigation stack, and remove until the last page with `toUrl` satisfies the `predicate`.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveUntil<TParams, TPopParams>({
    required final String url,
    required final bool Function(String url) predicate,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared().pushAndRemoveUntil<TParams, TPopParams>(
        url: url,
        predicate: predicate,
        params: params,
        animated: animated,
        result: result,
      );

  /// Push the page onto the navigation stack, and remove until the first page with `toUrl` satisfies the `predicate`.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveUntilFirst<TParams, TPopParams>({
    required final String url,
    required final bool Function(String url) predicate,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigatorImplement.shared()
          .pushAndRemoveUntilFirst<TParams, TPopParams>(
        url: url,
        predicate: predicate,
        params: params,
        animated: animated,
        result: result,
      );

  /// Send a notification to all page.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyAll<TParams>({
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared()
          .notifyAll<TParams>(name: name, params: params);

  /// Send a notification to the last page with `url`.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notify<TParams>({
    required final String url,
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyLast<TParams>(
        url: url,
        name: name,
        params: params,
      );

  /// Send a notification to the first page with `url`.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyFrist<TParams>({
    required final String url,
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyFirst<TParams>(
        url: url,
        name: name,
        params: params,
      );

  /// Send a notification to the first page with `url` satisfies the `predicate`.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyFirstWhere<TParams>({
    required final bool Function(String url) predicate,
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyFirstWhere<TParams>(
        predicate: predicate,
        name: name,
        params: params,
      );

  /// Send a notification to all pages with `url` satisfies the `predicate`.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyWhere<TParams>({
    required final bool Function(String url) predicate,
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyWhere<TParams>(
        predicate: predicate,
        name: name,
        params: params,
      );

  /// Send a notification to the last page with `url` satisfies the `predicate`.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyLastWhere<TParams>({
    required final bool Function(String url) predicate,
    required final String name,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyLastWhere<TParams>(
        predicate: predicate,
        name: name,
        params: params,
      );

  static Future<TResult?> act<TParams, TResult>({
    required final String url,
    required final String action,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared()
          .act<TParams, TResult>(url: url, action: action, params: params);

  /// Maybe pop a page from the navigation stack.
  ///
  static Future<bool> maybePop<TParams>({
    final TParams? params,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().maybePop<TParams>(
        params: params,
        animated: animated,
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

  /// Pop the page in the navigation stack until the first page.
  ///
  static Future<bool> popToRoot({final bool animated = true}) =>
      ThrioNavigatorImplement.shared().popToRoot(animated: animated);

  /// Pop the page in the navigation stack until the last page with `url`.
  ///
  static Future<bool> popTo({
    required final String url,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().popTo(
        url: url,
        animated: animated,
      );

  /// Pop the page in the navigation stack until the first page with `url`.
  ///
  static Future<bool> popToFirst({
    required final String url,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().popToFirst(
        url: url,
        animated: animated,
      );

  /// Pop the page in the navigation stack until the last page with `url` satisfies the `predicate`.
  ///
  static Future<bool> popUntil({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared()
          .popUntil(predicate: predicate, animated: animated);

  /// Pop the page in the navigation stack until the first page with `url` satisfies the `predicate`.
  ///
  static Future<bool> popUntilFirst({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared()
          .popUntilFirst(predicate: predicate, animated: animated);

  /// Remove the last page with `url` in the navigation stack.
  ///
  static Future<bool> remove({
    required final String url,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().remove(
        url: url,
        animated: animated,
      );

  /// Remove the first page with `url` in the navigation stack.
  ///
  static Future<bool> removeFirst({
    required final String url,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().removeFirst(
        url: url,
        animated: animated,
      );

  /// Remove pages below the last page in the navigation stack.
  /// Until the last page with `url` satisfies the `predicate`.
  ///
  static Future<bool> removeBlowUntil({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().removeBlowUntil(
        predicate: predicate,
        animated: animated,
      );

  /// Remove pages below the last page  in the navigation stack.
  /// Until the first page with `url` satisfies the `predicate`.
  ///
  static Future<bool> removeBlowUntilFirst({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().removeBlowUntilFirst(
        predicate: predicate,
        animated: animated,
      );

  /// Remove all pages with `url` in the navigation stack, except the one with index equals to `excludeIndex`.
  ///
  static Future<int> removeAll(
          {required final String url, final int excludeIndex = 0}) =>
      ThrioNavigatorImplement.shared()
          .removeAll(url: url, excludeIndex: excludeIndex);

  /// Replace the last flutter page with `newUrl` in the navigation stack.
  ///
  /// Both `url` and `newUrl` must be flutter page.
  ///
  static Future<int> replace({
    required final String url,
    required final String newUrl,
  }) =>
      ThrioNavigatorImplement.shared().replace(
        url: url,
        newUrl: newUrl,
      );

  /// Replace the first flutter page with `newUrl` in the navigation stack.
  ///
  /// Both `url` and `newUrl` must be flutter page.
  ///
  static Future<int> replaceFirst({
    required final String url,
    required final String newUrl,
  }) =>
      ThrioNavigatorImplement.shared().replaceFirst(
        url: url,
        newUrl: newUrl,
      );

  /// Whether the navigator can be popped.
  ///
  static Future<bool> canPop() => ThrioNavigatorImplement.shared().canPop();

  /// Build widget with `url` and `params`.
  ///
  static Widget? build<TParams>({
    required final String url,
    final int? index,
    final TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().build(
        url: url,
        index: index,
        params: params,
      );

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
  /// navigation stack matching `url` and `index`.
  ///
  static NavigatorRoute? lastFlutterRoute(
          {final String? url, final int? index}) =>
      ThrioNavigatorImplement.shared().lastFlutterRoute(url: url, index: index);

  /// Returns all flutter route of the page with `url` and `index` in the navigation stack.
  ///
  static List<NavigatorRoute> allFlutterRoutes(
          {final String? url, final int? index}) =>
      ThrioNavigatorImplement.shared().allFlutterRoutes(url: url, index: index);

  /// Returns true if there is a dialog route on the last matching `url` and `index`.
  static bool isDialogAbove({final String? url, final int? index}) =>
      ThrioNavigatorImplement.shared().isDialogAbove(url: url, index: index);
}
