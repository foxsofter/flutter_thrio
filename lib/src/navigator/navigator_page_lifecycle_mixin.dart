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
import 'navigator_types.dart';

mixin NavigatorPageLifecycleMixin<T extends StatefulWidget> on State<T> {
  late RouteSettings _current;
  VoidCallback? _currentObserverCallback;

  late RouteSettings _anchor;
  VoidCallback? _anchorObserverCallback;

  late final _currentObserver = _CurrentLifecycleObserver(this);

  @override
  void initState() {
    super.initState();
    if (mounted) {
      var settings = NavigatorPage.routeSettingsOf(context);
      _current = settings;
      while (settings.parent != null) {
        settings = settings.parent!;
        if (settings.isSelected != null) {
          break;
        }
      }
      _anchor = settings;
      if (_current.name != _anchor.name) {
        _anchorObserverCallback = anchor.pageLifecycleObservers.registry(
          _anchor.url,
          _AnchorLifecycleObserver(this),
        );
      } else {
        _currentObserverCallback = anchor.pageLifecycleObservers.registry(
          _current.url,
          _currentObserver,
        );
      }

      if (_current.parent == null || _current.isSelected != false) {
        Future(() => didAppear(_current));
      }
    }
  }

  void didAppear(final RouteSettings settings) {
    verbose('NavigatorPageLifecycleMixin didAppear: $settings');
  }

  void didDisappear(final RouteSettings settings) {
    verbose('NavigatorPageLifecycleMixin didDisappear: $settings');
  }

  @override
  void dispose() {
    _currentObserverCallback?.call();
    _anchorObserverCallback?.call();
    super.dispose();
  }
}

class _CurrentLifecycleObserver with NavigatorPageObserver {
  _CurrentLifecycleObserver(this.delegate);

  final NavigatorPageLifecycleMixin delegate;

  @override
  void didAppear(final RouteSettings routeSettings) {
    if (delegate._current.name == routeSettings.name) {
      delegate.didAppear(routeSettings);
    }
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    if (delegate._current.name == routeSettings.name) {
      delegate.didDisappear(routeSettings);
    }
  }
}

class _AnchorLifecycleObserver with NavigatorPageObserver {
  const _AnchorLifecycleObserver(this.delegate);

  final NavigatorPageLifecycleMixin delegate;

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = delegate._currentObserver.didAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = delegate._currentObserver.didDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  void _lifecycleCallback(
    final NavigatorPageObserverCallback? callback,
    final RouteSettings routeSettings,
  ) {
    final settings = delegate._anchor;
    if (settings.name == routeSettings.name &&
        delegate._current.isSelected != false) {
      callback?.call(delegate._current);
    }
  }
}
