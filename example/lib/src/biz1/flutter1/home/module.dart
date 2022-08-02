import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../../models/people.dart';
import 'page.dart' as flutter1;

class Module
    with
        ThrioModule,
        ModuleJsonSerializer,
        ModuleJsonDeserializer,
        ModuleParamScheme,
        ModulePageBuilder,
        ModulePageObserver,
        ModuleRouteTransitionsBuilder,
        NavigatorPageObserver {
  @override
  String get key => kNavigatorPageDefaultUrl;

  @override
  void onParamSchemeRegister(ModuleContext moduleContext) {
    registerParamScheme<double>('double_key_biz1_flutter1');
  }

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) => flutter1.Page(
          moduleContext: moduleContext,
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
