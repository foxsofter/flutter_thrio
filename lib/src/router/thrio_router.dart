// Copyright (c) 2019/11/25, 19:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import '../app/thrio_app.dart';

/// A class that provides push, pop, popTo and notify page functions.
///
class ThrioRouter {
  factory ThrioRouter() => _default;

  ThrioRouter._();

  static final _default = ThrioRouter._();

  /// Push a page with `url` onto native navigator.
  ///
  Future<bool> push(
    String url, {
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) =>
      ThrioApp().push(
        url,
        animated: animated,
        params: params,
      );

  /// Notify a page with `url` and `index`.
  ///
  Future<bool> notify(
    String name,
    String url, {
    int index = 0,
    Map<String, dynamic> params = const {},
  }) =>
      ThrioApp().notify(
        name,
        url,
        index: index,
        params: params,
      );

  /// Pop a page with `url` and `index` from native navigator.
  ///
  Future<bool> pop({
    String url = '',
    int index = 0,
    bool animated = true,
  }) =>
      ThrioApp().pop(
        url: url,
        index: index,
        animated: animated,
      );

  /// Pop to a page with `url` and `index`.
  ///
  Future<bool> popTo(
    String url, {
    int index = 0,
    bool animated = true,
  }) =>
      ThrioApp().popTo(
        url,
        index: index,
        animated: animated,
      );
}
