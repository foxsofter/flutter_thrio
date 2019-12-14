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
    RouterChannel().registryMethodCall(
      'scheduleFrame',
      _onScheduleFrame,
    );
    RouterChannel().registryMethodCall(
      'backPressed',
      _onBackPressed,
    );

    _onInited();
    _onWillAppear();
    _onAppeared();
    _onWillDisappear();
    _onDisappeared();
    _onDestroyed();
    _onBackground();
    _onForeground();
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

  void _onAppeared() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.appeared.castToString())
        .listen((arguments) {
      if (Platform.isAndroid) {
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
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.appeared,
      );
    });
  }

  void _onBackground() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.background.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      if (Router().current.routeSettings == routeSettings) {
        Router().navigatorState?.sendToBack();
      }
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.background,
      );
    });
  }

  Future _onBackPressed([_]) async {
    final state = Router().current?.tryStateOf<RouterContainerState>();
    if (state != null) {
      return state.backPressed();
    }
    return false;
  }

  void _onDestroyed() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.destroyed.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.destroyed,
      );
    });
  }

  void _onDisappeared() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.disappeared.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.disappeared,
      );
    });
  }

  void _onForeground() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.foreground.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      if (Router().current.routeSettings == routeSettings) {
        Router().navigatorState?.bringToFront();
      }
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.foreground,
      );
    });
  }

  void _onInited() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.inited.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.inited,
      );
    });
  }

  Future _onScheduleFrame([_]) {
    WidgetsBinding.instance.scheduleForcedFrame();
    return Future.delayed(
      const Duration(milliseconds: 250),
      WidgetsBinding.instance.scheduleForcedFrame,
    );
  }

  void _onWillAppear() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.willAppear.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);

      Router().navigatorState?.push(routeSettings);

      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.willAppear,
      );
    });
  }

  void _onWillDisappear() {
    RouterChannel()
        .onEventStream(RouterContainerLifecycle.willDisappear.castToString())
        .listen((arguments) {
      final routeSettings = Router().argumentsToRouteSettings(arguments);
      onLifecycleChanged(
        routeSettings,
        RouterContainerLifecycle.willDisappear,
      );
    });
  }
}
