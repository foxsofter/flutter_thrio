import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter1/module.dart' as flutter1;
import 'flutter3/module.dart' as flutter3;

class Module
    with
        ThrioModule,
        ModulePageObserver,
        ModuleParamScheme,
        ModuleRouteTransitionsBuilder,
        NavigatorPageObserver {
  @override
  String get key => 'biz1';

  @override
  void onModuleRegister(ModuleContext moduleContext) {
    registerModule(flutter1.Module(), moduleContext);
    registerModule(flutter3.Module(), moduleContext);
  }

  @override
  void onParamSchemeRegister(ModuleContext moduleContext) {
    registerParamScheme<String>('string_key_biz1');
  }

  @override
  void onPageObserverRegister(ModuleContext moduleContext) {
    registerPageObserver(this);
  }

  @override
  void onRouteTransitionsBuilderSetting(ModuleContext moduleContext) {
    routeTransitionsBuilder = (
      context,
      animation,
      secondaryAnimation,
      child,
    ) =>
        SlideTransition(
          position: Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.ease,
          )),
          child: child,
        );
  }

  @override
  void didAppear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 didAppear: $routeSettings');
  }

  @override
  void didDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 didDisappear: $routeSettings');
  }

  @override
  void willAppear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 willAppear: $routeSettings');
  }

  @override
  void willDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 willDisappear: $routeSettings');
  }
}
