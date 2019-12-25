// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/stateful_widget.dart';
import '../logger/thrio_logger.dart';
import '../registry/registry_set_map.dart';
import '../thrio_types.dart';
import 'thrio_page.dart';
import 'thrio_route_settings.dart';
import 'thrio_router.dart';

class ThrioPageObserver {
  ThrioPageObserver() {
    ThrioChannel().registryMethodCall(
      'scheduleFrame',
      _onScheduleFrame,
    );
    ThrioChannel().registryMethodCall(
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

  final _lifecycleHandlers =
      RegistrySetMap<ThrioRouteSettings, PageLifecycleHandler>();

  final _navigationHandlers =
      RegistrySetMap<ThrioRouteSettings, NavigationEventHandler>();

  void _onLifecycleChanged(
    ThrioRouteSettings routeSettings,
    PageLifecycle lifecycle,
  ) {
    final handlers = _lifecycleHandlers[routeSettings];
    for (final it in handlers) {
      it(routeSettings, lifecycle);
    }
  }

  void onNavigatorEventChanged(
    ThrioRouteSettings routeSettings,
    NavigationEvent navigation,
  ) {
    final handlers = _navigationHandlers[routeSettings];
    for (final it in handlers) {
      it(routeSettings, navigation);
    }
  }

  VoidCallback registryLifecycleHandler(
    ThrioRouteSettings routeSettings,
    PageLifecycleHandler handler,
  ) =>
      _lifecycleHandlers.registry(routeSettings, handler);

  VoidCallback registryNavigationHandler(
    ThrioRouteSettings routeSettings,
    NavigationEventHandler handler,
  ) =>
      _navigationHandlers.registry(routeSettings, handler);

  void _onAppeared() {
    ThrioChannel()
        .onEventStream(PageLifecycle.appeared.toString())
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
          ThrioLogger().e(e.toString());
        }
      }
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.appeared,
      );
    });
  }

  void _onBackground() {
    ThrioChannel()
        .onEventStream(PageLifecycle.background.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      if (ThrioRouter().current.routeSettings == routeSettings) {
        ThrioRouter().navigatorState?.sendToBack();
      }
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.background,
      );
    });
  }

  Future _onBackPressed([_]) async {
    final state = ThrioRouter().current?.tryStateOf<ThrioPageState>();
    if (state != null) {
      return state.backPressed();
    }
    return false;
  }

  void _onDestroyed() {
    ThrioChannel()
        .onEventStream(PageLifecycle.destroyed.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.destroyed,
      );
    });
  }

  void _onDisappeared() {
    ThrioChannel()
        .onEventStream(PageLifecycle.disappeared.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.disappeared,
      );
    });
  }

  void _onForeground() {
    ThrioChannel()
        .onEventStream(PageLifecycle.foreground.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      if (ThrioRouter().current.routeSettings == routeSettings) {
        ThrioRouter().navigatorState?.bringToFront();
      }
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.foreground,
      );
    });
  }AppLifecycleState s;

  void _onInited() {
    ThrioChannel()
        .onEventStream(PageLifecycle.inited.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.inited,
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
    ThrioChannel()
        .onEventStream(PageLifecycle.willAppear.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);

      ThrioRouter().navigatorState?.push(routeSettings);

      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.willAppear,
      );
    });
  }

  void _onWillDisappear() {
    ThrioChannel()
        .onEventStream(PageLifecycle.willDisappear.toString())
        .listen((arguments) {
      final routeSettings = ThrioRouter().argumentsToRouteSettings(arguments);
      _onLifecycleChanged(
        routeSettings,
        PageLifecycle.willDisappear,
      );
    });
  }
}
