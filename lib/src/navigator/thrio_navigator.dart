// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../app/thrio_app.dart';
import '../extension/stateful_widget.dart';
import '../logger/thrio_logger.dart';
import 'thrio_page_route.dart';
import 'thrio_route_settings.dart';

/// A widget that manages a set of child widgets with a stack discipline.
///
class ThrioNavigator extends StatefulWidget {
  const ThrioNavigator({
    Key key,
    this.child,
  }) : super(key: key);

  final Navigator child;

  /// Push a page with `url` onto native navigator.
  ///
  static Future<bool> push({
    @required String url,
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) =>
      ThrioApp().push(
        url: url,
        animated: animated,
        params: params,
      );

  /// Notify a page with `url` and `index`.
  ///
  static Future<bool> notify({
    @required String name,
    @required String url,
    int index = 0,
    Map<String, dynamic> params = const {},
  }) =>
      ThrioApp().notify(
        name: name,
        url: url,
        index: index,
        params: params,
      );

  /// Pop a page with `url` and `index` from native navigator.
  ///
  static Future<bool> pop({
    String url = '',
    int index = 0,
    bool animated = true,
  }) =>
      ThrioApp().pop(
        url: url,
        index: index,
        animated: animated,
      );

  /// Pop to a page with `url` and `index`.
  ///
  static Future<bool> popTo({
    @required String url,
    int index = 0,
    bool animated = true,
  }) =>
      ThrioApp().popTo(
        url: url,
        index: index,
        animated: animated,
      );

  @override
  State<StatefulWidget> createState() => ThrioNavigatorState();
}

class ThrioNavigatorState extends State<ThrioNavigator> {
  final _pageRoutes = <ThrioPageRoute>[];
  ThrioPageRoute get current => _pageRoutes.last;

  Future<bool> push(RouteSettings settings) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final pageBuilder = ThrioApp().pageBuilder(settings.url);
    final route = ThrioPageRoute(builder: pageBuilder, settings: settings);
    navigatorState.push(route);
    _pageRoutes.add(route);

    ThrioLogger().v('push: ${route.settings}');

    return Future.value(true);
  }

  Future<bool> pop(RouteSettings settings) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final route = _pageRoutes.lastWhere(
        (it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null) {
      return Future.value(false);
    }

    ThrioLogger().v('pop: ${route.settings}');

    if (settings.name == current.settings.name) {
      navigatorState.pop();
    } else {
      navigatorState.removeRoute(route);
    }

    _pageRoutes.remove(route);

    return Future.value(true);
  }

  Future<bool> popTo(RouteSettings settings) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final route = _pageRoutes.lastWhere(
        (it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null || settings.name == current.settings.name) {
      return Future.value(false);
    }
    navigatorState.popUntil((it) => it.settings.name == settings.name);

    _pageRoutes.removeRange(
        _pageRoutes.lastIndexOf(route) + 1, _pageRoutes.length);

    ThrioLogger().v('popTo: ${route.settings}');

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
