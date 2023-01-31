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

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

import '../module/module_anchor.dart';
import 'navigator_logger.dart';
import 'navigator_page.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';

mixin NavigatorPageLifecycleMixin<T extends StatefulWidget> on State<T> {
  late RouteSettings _current;
  late final _currentObserver = _CurrentLifecycleObserver(this);
  VoidCallback? _currentObserverCallback;

  late List<RouteSettings> _anchors;
  VoidCallback? _anchorsObserverCallback;

  final _initAppear = AsyncMemoizer<void>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _init();
    _initAppear.runOnce(() {
      if (!_current.isBuilt || (_current.isSelected != false)) {
        Future(() => didAppear(_current));
      }
    });
  }

  @override
  void didUpdateWidget(final T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  void didAppear(final RouteSettings settings) {
    verbose('NavigatorPageLifecycleMixin didAppear: ${settings.name}');
  }

  void didDisappear(final RouteSettings settings) {
    verbose('NavigatorPageLifecycleMixin didDisappear: ${settings.name}');
  }

  @override
  void dispose() {
    _currentObserverCallback?.call();
    _anchorsObserverCallback?.call();
    super.dispose();
  }

  void _init() {
    _current = NavigatorPage.routeSettingsOf(context);
    _currentObserverCallback?.call();
    _currentObserverCallback =
        anchor.pageLifecycleObservers.registry(_current.url, _currentObserver);

    _anchors = NavigatorPage.routeSettingsListOf(context);
    // 链路上重复的 settings 要去掉
    _anchors.removeWhere((final it) => it.name == _current.name);

    _anchorsObserverCallback?.call();
    final observers = <String, NavigatorPageObserver>{};
    for (final it in _anchors) {
      observers[it.url] = _AnchorLifecycleObserver(this, it);
    }
    if (_anchors.isNotEmpty) {
      _anchorsObserverCallback =
          anchor.pageLifecycleObservers.registryAll(observers);
    }
  }
}

class _CurrentLifecycleObserver with NavigatorPageObserver {
  _CurrentLifecycleObserver(this._delegate);

  final NavigatorPageLifecycleMixin _delegate;

  @override
  RouteSettings? get settings => _delegate._current;

  @override
  void didAppear(final RouteSettings routeSettings) {
    if (_delegate._current.name == routeSettings.name &&
        routeSettings.isSelected != false) {
      _delegate.didAppear(routeSettings);
    }
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    if (_delegate._current.name == routeSettings.name &&
        routeSettings.isSelected != false) {
      _delegate.didDisappear(routeSettings);
    }
  }
}

class _AnchorLifecycleObserver with NavigatorPageObserver {
  const _AnchorLifecycleObserver(this._delegate, this.settings);

  final NavigatorPageLifecycleMixin _delegate;

  @override
  final RouteSettings settings;

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = _delegate._currentObserver.didAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = _delegate._currentObserver.didDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  void _lifecycleCallback(
    final void Function(RouteSettings) callback,
    final RouteSettings routeSettings,
  ) {
    if (settings.name != routeSettings.name ||
        _delegate._current.isSelected == false) {
      return;
    }
    final idx = _delegate._anchors
        .indexWhere((final it) => it.name == routeSettings.name);
    final ins = _delegate._anchors.sublist(0, idx);
    if (ins.every((final it) => it.isSelected == true)) {
      callback(_delegate._current);
    }
  }
}
