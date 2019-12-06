// Copyright (c) 2019/11/25, 19:27:59 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'router.dart';
import 'router_predicate.dart';

/// A class that provides push, pop, and notify page functions.
///
class ThrioRouter {
  // This class is only a namespace, and should not be instantiated or
  // extended directly.
  factory ThrioRouter._() => null;

  /// Push a page with `url` onto the topmost native navigator.
  ///
  static Future<bool> push(
    String url, {
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) =>
      Router().push(
        url,
        animated: animated,
        params: params,
      );

  /// Pop a page with `url` and `index` from the topmost native navigator.
  static Future<bool> pop(
    String url, {
    int index = 0,
    bool animated = true,
  }) =>
      Router().pop(
        url,
        index: index,
        animated: animated,
      );

  /// Pop to a page with `url` and `index`.
  static Future<bool> popTo(
    String url, {
    int index = 0,
    bool animated = true,
  }) =>
      Router().popTo(
        url,
        index: index,
        animated: animated,
      );

  /// Notify a page with `url` and `index`.
  static Future<bool> notify(
    String url, {
    int index = 0,
    Map<String, dynamic> params = const {},
  }) =>
      Router().notify(
        url,
        index: index,
        params: params,
      );

  /// Register an interceptor for the router.
  ///
  /// Unregister by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPredicate(RouterPredicate predicate) =>
      Router().registerPredicate(predicate);
}
