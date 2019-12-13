// Copyright (c) 2019/11/28, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

/// Signature of predicate that can navigation or not.
///
typedef NavigationPredicate = Future<bool> Function(
  String url, {
  int index,
  Map<String, dynamic> params,
});

/// A class represents a predicate that can route or not.
///
class RouterPredicate {
  RouterPredicate({
    NavigationPredicate onPush,
    NavigationPredicate onPop,
    NavigationPredicate onPopTo,
    NavigationPredicate onNotify,
  })  : _canPush = onPush,
        _canPop = onPop,
        _canPopTo = onPopTo,
        _canNotify = onNotify;

  final NavigationPredicate _canPush;

  final NavigationPredicate _canPop;

  final NavigationPredicate _canPopTo;

  final NavigationPredicate _canNotify;

  /// Will be executed before the `notify` is performed.
  ///
  /// If you want to stop the `notify`, return false.
  ///
  Future<bool> canNotify(
    String url, {
    int index = 0,
    Map<String, dynamic> params = const {},
  }) {
    if (_canNotify != null) {
      return _canNotify(url, index: index, params: params);
    }
    return Future<bool>.value(true);
  }

  /// Will be executed before the `pop` is performed.
  ///
  /// If you want to stop the `pop`, return false.
  ///
  Future<bool> canPop(
    String url, {
    int index = 0,
  }) {
    if (_canPop != null) {
      return _canPop(url, index: index);
    }
    return Future<bool>.value(true);
  }

  /// Will be executed before the `popTo` is performed.
  ///
  /// If you want to stop the `popTo`, return false.
  ///
  Future<bool> canPopTo(
    String url, {
    int index = 0,
  }) {
    if (_canPopTo != null) {
      return _canPopTo(url, index: index);
    }
    return Future<bool>.value(true);
  }

  /// Will be executed before the `push` is performed.
  ///
  /// If you want to stop the `push`, return false.
  ///
  Future<bool> canPush(
    String url, {
    Map<String, dynamic> params = const {},
  }) {
    if (_canPush != null) {
      return _canPush(url, params: params);
    }
    return Future<bool>.value(true);
  }
}
