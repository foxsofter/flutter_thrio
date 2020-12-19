import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import '../../models/people.dart';
import 'flutter1.dart';

class Module
    with
        ThrioModule,
        ModuleJsonSerializer,
        ModuleJsonDeserializer,
        ModulePageBuilder,
        ModulePageObserver,
        ModuleRouteTransitionsBuilder,
        NavigatorPageObserver {
  @override
  String get key => 'flutter1';

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) => Flutter1(
          index: settings.index,
          params: settings.params,
        );
  }

  @override
  void onJsonSerializerRegister(ModuleContext moduleContext) {
    registerJsonSerializer<People>((instance) => instance<People>().toJson());
  }

  @override
  void onJsonDeserializerRegister(ModuleContext moduleContext) {
    registerJsonDeserializer((arguments) => People.fromJson(arguments));
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
          transformHitTests: false,
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, 1),
            ).animate(secondaryAnimation),
            child: child,
          ),
        );
  }

  @override
  void didAppear(RouteSettings routeSettings) {
    ThrioLogger.v('flutter1 didAppear: $routeSettings');
  }

  @override
  void didDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('flutter1 didDisappear: $routeSettings');
  }

  @override
  void willAppear(RouteSettings routeSettings) {
    ThrioLogger.v('flutter1 willAppear: $routeSettings');
  }

  @override
  void willDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('flutter1 willDisappear: $routeSettings');
  }
}
