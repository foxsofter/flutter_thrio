// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'extension/router_container_lifecycle.dart';
import 'extension/stateful_widget.dart';
import 'registry/registry_set_map.dart';
import 'router.dart';
import 'router_channel.dart';
import 'router_container.dart';
import 'router_logger.dart';
import 'router_route_settings.dart';
import 'thrio_types.dart';

class RouterContainerObserver {
  factory RouterContainerObserver() => _default;

  RouterContainerObserver._() {
    RouterChannel().onMethodCall(
      'backPressed',
      _onBackPressed,
    );
    RouterChannel().onMethodCall(
      'lifecycle',
      _onLifecycleChanged,
    );
    RouterChannel().onMethodCall(
      'scheduleFrame',
      _onScheduleFrame,
    );
  }

  static final _default = RouterContainerObserver._();

  final _lifecycleHandlers =
      RegistrySetMap<RouterRouteSettings, RouterContainerLifecycleHandler>();

  final _navigationHandlers =
      RegistrySetMap<RouterRouteSettings, RouterContainerNavigationHandler>();

  void onLifecycleChanged(
    RouterRouteSettings routeSettings,
    RouterContainerLifecycle lifecycle,
  ) {
    final handlers = _lifecycleHandlers[routeSettings];
    for (final it in handlers) {
      it(routeSettings, lifecycle);
    }
    if (Router().current.routeSettings == routeSettings) {
      switch (lifecycle) {
        case RouterContainerLifecycle.foreground:
          Router().navigatorState?.bringToFront();
          break;
        case RouterContainerLifecycle.background:
          Router().navigatorState?.sendToBack();
          break;
        default:
      }
    }
  }

  void onNavigationChanged(
    RouterRouteSettings routeSettings,
    RouterContainerNavigation navigation,
  ) {
    final handlers = _navigationHandlers[routeSettings];
    for (final it in handlers) {
      it(routeSettings, navigation);
    }
  }

  VoidCallback registryLifecycleHandler(
    RouterRouteSettings routeSettings,
    RouterContainerLifecycleHandler handler,
  ) =>
      _lifecycleHandlers.registry(routeSettings, handler);

  VoidCallback registryNavigationHandler(
    RouterRouteSettings routeSettings,
    RouterContainerNavigationHandler handler,
  ) =>
      _navigationHandlers.registry(routeSettings, handler);

  Future _onBackPressed([_]) async {
    final state = Router().current?.tryStateOf<RouterContainerState>();
    if (state != null) {
      return state.backPressed();
    }
    return false;
  }

  Future _onLifecycleChanged([Map<String, dynamic> arguments]) async {
    final lifecycleValue = arguments['lifecycle'];
    final lifecycle = RouterContainerLifecycleX.castFromString(
        lifecycleValue is String ? lifecycleValue : null);

    final routeSettings = Router().argumentsToRouteSettings(arguments);

    if (lifecycle == RouterContainerLifecycle.appeared && Platform.isAndroid) {
      try {
        final owner = WidgetsBinding.instance.pipelineOwner?.semanticsOwner;
        final root = owner?.rootSemanticsNode;
        root?.detach();
        root?.attach(owner);
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        RouterLogger.e(e.toString());
      }
    }
    if (lifecycle == RouterContainerLifecycle.willAppear) {
      Router().navigatorState?.push(routeSettings);
    }

    onLifecycleChanged(routeSettings, lifecycle);
  }

  Future _onScheduleFrame([_]) {
    WidgetsBinding.instance.scheduleForcedFrame();
    return Future.delayed(
      Duration(milliseconds: 250),
      WidgetsBinding.instance.scheduleForcedFrame,
    );
  }
}
