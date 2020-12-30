import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import 'page.dart' as flutter2;

class Module
    with ThrioModule, ModulePageBuilder, ModuleRouteTransitionsBuilder {
  @override
  String get key => 'flutter2';

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) => flutter2.Page(
          index: settings.index,
          params: settings.params,
        );
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
}
