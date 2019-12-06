// Copyright (c) 2019/12/03, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/material.dart';

import 'registry/registry_set.dart';

typedef DidPushHandler = void Function(
  Route route,
  Route previousRoute,
);
typedef DidPopHandler = void Function(
  Route route,
  Route previousRoute,
);
typedef DidRemoveHandler = void Function(
  Route route,
  Route previousRoute,
);
typedef DidReplaceHandler = void Function(
  Route newRoute,
  Route oldRoute,
);

class RouterNavigatorObserver extends NavigatorObserver {
  VoidCallback registryDidPush(DidPushHandler handler) =>
      _pushHandlers.registry(handler);

  VoidCallback registryDidPop(DidPopHandler handler) =>
      _popHandlers.registry(handler);

  VoidCallback registryDidRemove(DidRemoveHandler handler) =>
      _removeHandlers.registry(handler);

  VoidCallback registryDidReplace(DidReplaceHandler handler) =>
      _replaceHandlers.registry(handler);

  @override
  void didPush(Route route, Route previousRoute) {
    for (final it in _pushHandlers) {
      it(route, previousRoute);
    }
  }

  @override
  void didPop(Route route, Route previousRoute) {
    for (final it in _popHandlers) {
      it(route, previousRoute);
    }
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    for (final it in _removeHandlers) {
      it(route, previousRoute);
    }
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    for (final it in _replaceHandlers) {
      it(newRoute, oldRoute);
    }
  }

  void clear() {
    _pushHandlers.unregistryAll();
    _popHandlers.unregistryAll();
    _removeHandlers.unregistryAll();
    _replaceHandlers.unregistryAll();
  }

  final _pushHandlers = RegistrySet<DidPushHandler>();
  final _popHandlers = RegistrySet<DidPopHandler>();
  final _removeHandlers = RegistrySet<DidRemoveHandler>();
  final _replaceHandlers = RegistrySet<DidReplaceHandler>();
}
