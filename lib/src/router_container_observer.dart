// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'extension/stateful_widget.dart';
import 'registry/registry_set_map.dart';
import 'router.dart';
import 'router_channel.dart';
import 'router_container.dart';
import 'router_navigator.dart';
import 'router_route_settings.dart';

typedef RouterContainerLifeCycleHandler = void Function(
  RouterRouteSettings routeSettings,
  RouterContainerLifeCycle lifeCycle,
);

typedef RouterContainerNavigationHandler = void Function(
  RouterRouteSettings routeSettings,
  RouterContainerNavigation navigationState,
);

enum RouterContainerLifeCycle {
  inited,
  appeared,
  willDisappeared,
  disappeared,
  destroyed,
  background,
  foreground,
}

extension RouterContainerLifeCycleX on RouterContainerLifeCycle {
  String castToString() => toString().split('.').last;

  static RouterContainerLifeCycle castFromString(String value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    const lifeCycles = <String, RouterContainerLifeCycle>{
      'inited': RouterContainerLifeCycle.inited,
      'appeared': RouterContainerLifeCycle.appeared,
      'willDisappeared': RouterContainerLifeCycle.willDisappeared,
      'disappeared': RouterContainerLifeCycle.disappeared,
      'destroyed': RouterContainerLifeCycle.destroyed,
      'background': RouterContainerLifeCycle.background,
      'foreground': RouterContainerLifeCycle.foreground,
    };
    return lifeCycles[value];
  }
}

enum RouterContainerNavigation {
  push,
  activate,
  pop,
  remove,
}

class RouterContainerObserver {
  factory RouterContainerObserver() => _default;

  RouterContainerObserver._() {
    RouterChannel().registryMethodHandler(
      'backPressed',
      _onBackPressed,
    );
    RouterChannel().registryMethodHandler(
      'lifeCycle',
      _onLifeCycleChanged,
    );
    RouterChannel().registryMethodHandler(
      'scheduleFrame',
      _onScheduleFrame,
    );
  }

  static final _default = RouterContainerObserver._();

  final _lifeCycleHandlers =
      RegistrySetMap<RouterRouteSettings, RouterContainerLifeCycleHandler>();

  final _navigationHandlers =
      RegistrySetMap<RouterRouteSettings, RouterContainerNavigationHandler>();

  void onLifeCycleChanged(
    RouterRouteSettings routeSettings,
    RouterContainerLifeCycle lifeCycle,
  ) {
    final handlers = _lifeCycleHandlers[routeSettings];
    for (final it in handlers) {
      it(routeSettings, lifeCycle);
    }
    if (Router().current.routeSettings == routeSettings) {
      switch (lifeCycle) {
        case RouterContainerLifeCycle.foreground:
          Router().navigator.tryStateOf<RouterNavigatorState>()?.bringToFront();
          break;
        case RouterContainerLifeCycle.background:
          Router().navigator.tryStateOf<RouterNavigatorState>()?.sendToBack();
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

  VoidCallback registryLifeCycleHandler(
    RouterRouteSettings routeSettings,
    RouterContainerLifeCycleHandler handler,
  ) =>
      _lifeCycleHandlers.registry(routeSettings, handler);

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

  Future _onLifeCycleChanged([Map<String, dynamic> arguments]) async {
    final lifeCycleValue = arguments['lifeCycle'];
    final lifeCycle = RouterContainerLifeCycleX.castFromString(
        lifeCycleValue is String ? lifeCycleValue : null);

    final routeSettings = Router().argumentsToRouteSettings(arguments);

    onLifeCycleChanged(routeSettings, lifeCycle);
  }

  Future _onScheduleFrame([_]) {
    WidgetsBinding.instance.scheduleForcedFrame();
    return Future.delayed(
      Duration(milliseconds: 250),
      WidgetsBinding.instance.scheduleForcedFrame,
    );
  }
}
