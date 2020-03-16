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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../extension/thrio_stateful_widget.dart';
import '../logger/thrio_logger.dart';
import 'navigator_page_route.dart';
import 'navigator_route_observer.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator.dart';

/// A widget that manages a set of child widgets with a stack discipline.
///
class NavigatorWidget extends StatefulWidget {
  const NavigatorWidget({
    Key key,
    NavigatorRouteObserver observer,
    this.child,
  })  : _observer = observer,
        super(key: key);

  final Navigator child;

  final NavigatorRouteObserver _observer;

  @override
  State<StatefulWidget> createState() => NavigatorWidgetState();
}

class NavigatorWidgetState extends State<NavigatorWidget> {
  List<NavigatorPageRoute> get history => widget._observer.pageRoutes;

  /// 还无法实现animated=false
  Future<bool> push(
    RouteSettings settings, {
    bool animated = true,
    NavigatorParamsCallback poppedResult,
  }) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }

    var pageBuilder = ThrioNavigator.getPageBuilder(settings.url);
    var purposeSettings = settings;

    //使用缺省页面
    if (pageBuilder == null) {
      pageBuilder = ThrioNavigator.getPageBuilder(Navigator.defaultRouteName);
      if (pageBuilder == null) {
        return Future.value(false);
      }
      var arguments = settings.toArguments();
      arguments['url'] = Navigator.defaultRouteName;
      purposeSettings = NavigatorRouteSettings.fromArguments(arguments);
    }

    final route = NavigatorPageRoute(
      builder: pageBuilder,
      settings: purposeSettings,
      poppedResult: poppedResult,
    );
    ThrioLogger().v('push: ${route.settings}');
    navigatorState.push(route);

    return Future.value(true);
  }

  Future<bool> maybePop(RouteSettings settings, {bool animated = true}) async {
    if (await history.last.willPop() != RoutePopDisposition.pop) {
      return false;
    }

    ThrioLogger().v('maybePop: ${history.last.settings}');
    return pop(settings, animated: animated);
  }

  Future<bool> pop(RouteSettings settings, {bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    if (history.isEmpty || settings.name != history.last.settings.name) {
      return false;
    }

    ThrioLogger().v('pop: ${history.last.settings}');
    var result = true;
    if (animated) {
      result = navigatorState.pop();
    } else {
      navigatorState.removeRoute(history.last);
    }
    return result;
  }

  Future<bool> popTo(RouteSettings settings, {bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    final route = history.lastWhere((it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null || settings.name == history.last.settings.name) {
      return false;
    }
    ThrioLogger().v('popTo: ${route.settings}');
    if (animated) {
      navigatorState.popUntil((it) => it.settings.name == settings.name);
    } else {
      for (var i = history.length - 2; i >= 0; i--) {
        if (history[i].settings.name == settings.name) {
          break;
        }
        navigatorState.removeRoute(history[i]);
      }
      navigatorState.removeRoute(history.last);
    }
    return true;
  }

  Future<bool> remove(RouteSettings settings, {bool animated = false}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    final route = history.lastWhere((it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null) {
      return false;
    }
    ThrioLogger().v('remove: ${route.settings}');
    if (settings.name == history.last.settings.name) {
      return pop(settings, animated: animated);
    }
    navigatorState.removeRoute(route);
    return true;
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      widget.child.observers.add(widget._observer);
      ThrioNavigator.ready();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
