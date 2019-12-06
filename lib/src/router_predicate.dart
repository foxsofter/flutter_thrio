// Copyright (c) 2019/11/28, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

/// Signature of predicate that can `ThrioRouter.push`.
typedef PushPredicate = Future<bool> Function(
  String url, {
  bool animated,
  Map<String, dynamic> params,
});

/// Signature of predicate that can `ThrioRouter.pop` or not.
typedef PopPredicate = Future<bool> Function(
  String url, {
  int index,
  bool animated,
});

/// Signature of predicate that can `ThrioRouter.popTo` or not.
typedef PopToPredicate = Future<bool> Function(
  String url, {
  int index,
  bool animated,
});

/// Signature of predicate that can `ThrioRouter.notify` or not.
typedef NotifyPredicate = Future<bool> Function(
  String url, {
  int index,
  Map<String, dynamic> params,
});

/// A class represents a predicate that can route or not.
///
class RouterPredicate {
  RouterPredicate({
    PushPredicate onPush,
    PopPredicate onPop,
    PopToPredicate onPopTo,
    NotifyPredicate onNotify,
  })  : _canPush = onPush,
        _canPop = onPop,
        _canPopTo = onPopTo,
        _canNotify = onNotify;

  /// Will be executed before the `push` is performed.
  ///
  /// If you want to stop the `push`, return false.
  ///
  Future<bool> canPush(
    String url, {
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) {
    if (_canPush != null) {
      return _canPush(url, animated: animated, params: params);
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
    bool animated = true,
  }) {
    if (_canPop != null) {
      return _canPop(url, index: index, animated: animated);
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
    bool animated = true,
  }) {
    if (_canPopTo != null) {
      return _canPopTo(url, index: index, animated: animated);
    }
    return Future<bool>.value(true);
  }

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

  final PushPredicate _canPush;
  final PopPredicate _canPop;
  final PopToPredicate _canPopTo;
  final NotifyPredicate _canNotify;
}
