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

import '../extension/thrio_build_context.dart';
import '../extension/thrio_iterable.dart';
import '../module/module_anchor.dart';
import 'navigator_page_observer.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

mixin NavigatorPageLifecycleMixin<T extends StatefulWidget> on State<T> {
  NavigatorRoute? _route;
  VoidCallback? _pageObserverCallback;

  String? get url => null;

  @override
  void initState() {
    super.initState();

    final state = context.tryStateOf<NavigatorWidgetState>();
    final route = url == null
        ? state?.history.last
        : state?.history.lastWhereOrNull(
            (final it) => it is NavigatorRoute && it.settings.url == url);
    if (route != null && route is NavigatorRoute) {
      Future(() => didAppear(route.settings));
    }
  }

  void didAppear(final RouteSettings settings) {}

  void didDisappear(final RouteSettings settings) {}

  @override
  void didChangeDependencies() {
    if (_pageObserverCallback != null) {
      _pageObserverCallback?.call();
      _pageObserverCallback = null;
    }
    if (url == null) {
      final state = context.stateOf<NavigatorWidgetState>();
      final route = state.history.last;
      if (route is NavigatorRoute) {
        _route = route;

        _pageObserverCallback = anchor.pageLifecycleObservers.registry(
          route.settings.url,
          _PageLifecyclePageObserver(this),
        );
      }
    } else {
      _pageObserverCallback = anchor.pageLifecycleObservers.registry(
        url!,
        _PageLifecyclePageObserver(this),
      );
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageObserverCallback?.call();
    super.dispose();
  }
}

class _PageLifecyclePageObserver with NavigatorPageObserver {
  const _PageLifecyclePageObserver(this.delegate);

  final NavigatorPageLifecycleMixin delegate;

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = delegate.didAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = delegate.didDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  void _lifecycleCallback(
    final NavigatorPageObserverCallback? callback,
    final RouteSettings routeSettings,
  ) {
    if (callback != null) {
      if (delegate.url == null) {
        final route = delegate._route;
        if (route != null && route.settings.name == routeSettings.name) {
          callback(route.settings);
        }
      } else {
        callback(routeSettings);
      }
    }
  }
}
