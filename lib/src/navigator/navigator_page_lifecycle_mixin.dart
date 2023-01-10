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

import 'package:flutter/widgets.dart';

import '../module/module_anchor.dart';
import 'navigator_logger.dart';
import 'navigator_page.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';

mixin NavigatorPageLifecycleMixin<T extends StatefulWidget> on State<T> {
  late RouteSettings _current;
  VoidCallback? _currentObserverCallback;

  final _anchors = <RouteSettings>[];
  final _anchorsObserverCallbacks = <VoidCallback>[];

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _init();

      if (_current.parent == null || (_current.isSelected == true)) {
        Future(() => didAppear(_current));
      }
    }
  }

  @override
  void didUpdateWidget(final T oldWidget) {
    _init();
    super.didUpdateWidget(oldWidget);
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
    for (final callback in _anchorsObserverCallbacks) {
      callback();
    }
    super.dispose();
  }

  void _init() {
    var settings = NavigatorPage.routeSettingsOf(context);
    _current = settings;
    _currentObserverCallback?.call();
    _currentObserverCallback = anchor.pageLifecycleObservers.registry(
      _current.url,
      _CurrentLifecycleObserver(this),
    );
    _anchors.clear();
    while (settings.parent != null) {
      settings = settings.parent!;
      if (settings.parent == null || settings.isSelected != null) {
        _anchors.add(settings);
      }
    }
    for (final callback in _anchorsObserverCallbacks) {
      callback();
    }
    _anchorsObserverCallbacks.clear();
    for (final it in _anchors) {
      _anchorsObserverCallbacks.add(anchor.pageLifecycleObservers.registry(
        it.url,
        _AnchorLifecycleObserver(this, it),
      ));
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
    if (_delegate._current.name == routeSettings.name) {
      _delegate.didAppear(routeSettings);
    }
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    if (_delegate._current.name == routeSettings.name) {
      _delegate.didDisappear(routeSettings);
    }
  }
}

class _AnchorLifecycleObserver with NavigatorPageObserver {
  const _AnchorLifecycleObserver(this._delegate, this._anchor);

  final NavigatorPageLifecycleMixin _delegate;

  final RouteSettings _anchor;

  @override
  RouteSettings? get settings => _anchor;

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = _delegate.didAppear;
    if (_anchor.name != routeSettings.name ||
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

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = _delegate.didDisappear;
    if (_anchor.name != routeSettings.name ||
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
