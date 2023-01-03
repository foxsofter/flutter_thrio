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
import 'navigator_page.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

mixin NavigatorPageLifecycleMixin<T extends StatefulWidget> on State<T> {
  RouteSettings? _settings;
  VoidCallback? _pageObserverCallback;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _settings = NavigatorRouteSettings.settingsWith(
        url: NavigatorPage.urlOf(context),
        index: NavigatorPage.indexOf(context),
      );
      _pageObserverCallback ??= anchor.pageLifecycleObservers.registry(
        _settings!.url,
        _PageLifecyclePageObserver(this),
      );
      final state = context.tryStateOf<NavigatorWidgetState>();
      if (state?.history.lastWhereOrNull(
              (final it) => it.settings.name == _settings?.name) !=
          null) {
        Future(() => didAppear(_settings!));
      }
    }
  }

  void didAppear(final RouteSettings settings) {}

  void didDisappear(final RouteSettings settings) {}

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
    final settings = delegate._settings;
    if (settings != null && settings.name == routeSettings.name) {
      callback?.call(settings);
    }
  }
}
