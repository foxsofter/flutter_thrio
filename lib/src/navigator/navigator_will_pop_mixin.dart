// The MIT License (MIT)
//
// Copyright (c) 2023 foxsofter.
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

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: prefer_mixin

import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

/// Handle a callback to veto attempts by the user to dismiss the enclosing
/// [ModalRoute].
///
mixin NavigatorWillPopMixin<T extends StatefulWidget> on State<T> {
  GlobalKey<NavigatorState> get internalNavigatorKey;

  /// Called to veto attempts by the user to dismiss the enclosing [ModalRoute].
  ///
  Future<bool> onWillPop() => Future.value(true);

  ModalRoute<dynamic>? _route;

  bool _added = false;

  VoidCallback? _callback;

  static final _observerMaps = <GlobalKey<NavigatorState>, NavigatorObserver>{};

  static NavigatorObserver navigatorObserverFor(
    GlobalKey<NavigatorState> navigatorStateKey,
  ) =>
      _observerMaps[navigatorStateKey] ??
      (_observerMaps[navigatorStateKey] = _InternalNavigatorObserver());

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _init();
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  void _init() {
    _callback?.call();
    final observer = navigatorObserverFor(internalNavigatorKey);
    if (observer is _InternalNavigatorObserver) {
      _callback = observer.delegates.registry(this);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _added = false;
    _route?.removeScopedWillPopCallback(onWillPop);
    _route = ModalRoute.of(context);
    _checkWillPop();
  }

  void _checkWillPop() {
    if (internalNavigatorKey.currentState?.canPop() == true) {
      if (!_added) {
        _added = true;
        _route?.addScopedWillPopCallback(onWillPop);
      }
    } else {
      if (_added) {
        _added = false;
        _route?.removeScopedWillPopCallback(onWillPop);
      }
    }
  }

  @override
  void dispose() {
    _added = false;
    _route?.removeScopedWillPopCallback(onWillPop);
    _callback?.call();
    super.dispose();
  }
}

class _InternalNavigatorObserver extends NavigatorObserver {
  final delegates = RegistrySet<NavigatorWillPopMixin>();

  @override
  void didPush(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    for (final it in delegates) {
      it._checkWillPop();
    }
  }

  @override
  void didPop(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    for (final it in delegates) {
      it._checkWillPop();
    }
  }

  @override
  void didRemove(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    for (final it in delegates) {
      it._checkWillPop();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    for (final it in delegates) {
      it._checkWillPop();
    }
  }
}
