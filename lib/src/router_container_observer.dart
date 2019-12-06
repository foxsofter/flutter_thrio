// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';

import 'registry/registry_set.dart';
import 'router_channel.dart';
import 'router_route_settings.dart';

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

  String castToString()=> toString().split('.').last;
  
  static RouterContainerLifeCycle castFromString(String value){
    if (value?.isEmpty ?? true) {
      return null;
    }
    const lifeCycles = <String, RouterContainerLifeCycle>{
      'inited':RouterContainerLifeCycle.inited,
      'appeared':RouterContainerLifeCycle.appeared,
      'willDisappeared': RouterContainerLifeCycle.willDisappeared,
      'disappeared': RouterContainerLifeCycle.disappeared,
      'destroyed': RouterContainerLifeCycle.destroyed,
      'background':RouterContainerLifeCycle.background,
      'foreground': RouterContainerLifeCycle.foreground,
    };
    return lifeCycles[value];
  }
}

typedef RouterContainerLifeCycleHandler = void Function(
  RouterRouteSettings routeSettings,
  RouterContainerLifeCycle lifeCycle,
);

enum RouterContainerNavigation {
  push,
  activate,
  pop,
  remove,
}

typedef RouterContainerNavigationHandler = void Function(
  RouterRouteSettings routeSettings,
  RouterContainerNavigation navigationState,
);

class RouterContainerObserver {
  factory RouterContainerObserver() => _default;

  RouterContainerObserver._() {
    RouterChannel().registryMethodHandler('backPressed', _onBackPressed,);
  }

  Future _onBackPressed(Map arguments) async {
    final url = arguments['url'] is String ? arguments['url'] : null;
    final index = arguments['index'] is int ? arguments['index'] : null;


  }

  final lifeCycleHandlers = RegistrySet<RouterContainerLifeCycleHandler>();

  final navigationHandlers = RegistrySet<RouterContainerNavigationHandler>();

  static final _default = RouterContainerObserver._();
}
