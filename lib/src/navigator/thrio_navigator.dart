// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../app/thrio_app.dart';
import '../extension/stateful_widget.dart';
import '../logger/thrio_logger.dart';
import '../registry/registry_map.dart';
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

  static final _pageBuilders = RegistryMap<String, ThrioPageBuilder>();

  /// Push a page with `url` onto `ThrioNavigator`.
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

  /// Pop a page from `ThrioNavigator`.
  ///
  static Future<bool> pop({bool animated = true}) =>
      ThrioApp().pop(animated: animated);

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

  /// Remove a page with `url` and `index` from `ThrioNavigator`.
  ///
  static Future<bool> remove({
    String url = '',
    int index = 0,
    bool animated = true,
  }) =>
      ThrioApp().remove(
        url: url,
        index: index,
        animated: animated,
      );

  /// Get the index of the last page.
  ///
  static Future<int> lastIndex({String url}) => ThrioApp().lastIndex(url: url);

  /// Get the index of all pages whose url is `url`.
  ///
  static Future<List<int>> allIndex(String index) => ThrioApp().allIndex(index);

  static VoidCallback registerDefaultPageBuilder(
    ThrioPageBuilder builder,
  ) =>
      _pageBuilders.registry(Navigator.defaultRouteName, builder);

  static VoidCallback registerPageBuilder(
    String url,
    ThrioPageBuilder builder,
  ) =>
      _pageBuilders.registry(url, builder);

  static VoidCallback registerPageBuilders(
    Map<String, ThrioPageBuilder> builders,
  ) =>
      _pageBuilders.registryAll(builders);

  @override
  State<StatefulWidget> createState() => ThrioNavigatorState();
}

class ThrioNavigatorState extends State<ThrioNavigator> {
  final _pageRoutes = <ThrioPageRoute>[];

  ThrioPageRoute get current => _pageRoutes.last;

  /// 还无法实现animated=false
  Future<bool> push(RouteSettings settings, {bool animated = true}) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final pageBuilder = ThrioNavigator._pageBuilders[settings.url];
    final route = ThrioPageRoute(builder: pageBuilder, settings: settings);
    navigatorState.push(route);
    _pageRoutes.add(route);
    ThrioLogger().v('push: ${route.settings}');
    return Future.value(true);
  }

  Future<bool> pop({bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    if (_pageRoutes.isEmpty) {
      return false;
    }
    if (animated) {
      if (await _pageRoutes.last.willPop() == RoutePopDisposition.pop) {
        navigatorState.pop();
        ThrioLogger().v('pop: ${_pageRoutes.last.settings}');
        _pageRoutes.removeLast();
      } else {
        return false;
      }
    } else {
      navigatorState.removeRoute(_pageRoutes.last);
      ThrioLogger().v('pop: ${_pageRoutes.last.settings}');
      _pageRoutes.removeLast();
    }
    return true;
  }

  Future<bool> popTo(RouteSettings settings, {bool animated = true}) {
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
    ThrioLogger().v('popTo: ${route.settings}');
    if (animated) {
      navigatorState.popUntil((it) => it.settings.name == settings.name);
      _pageRoutes.removeRange(
        _pageRoutes.lastIndexOf(route) + 1,
        _pageRoutes.length,
      );
    } else {
      for (var i = _pageRoutes.length - 2; i >= 0; i--) {
        if (_pageRoutes[i].settings.name == settings.name) {
          break;
        } else {
          navigatorState.removeRoute(_pageRoutes[i]);
          _pageRoutes.removeAt(i);
        }
      }
      navigatorState.removeRoute(_pageRoutes.last);
      _pageRoutes.removeLast();
    }
    return Future.value(true);
  }

  Future<bool> remove(RouteSettings settings, {bool animated = false}) {
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
    ThrioLogger().v('remove: ${route.settings}');
    if (settings.name == current.settings.name) {
      return pop(animated: animated);
    }
    navigatorState.removeRoute(route);
    _pageRoutes.remove(route);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
