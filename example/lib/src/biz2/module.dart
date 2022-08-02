import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter2/module.dart' as flutter2;
import 'flutter4/module.dart' as flutter4;

class Module with ThrioModule, ModulePageBuilder, ModuleRouteTransitionsBuilder {
  @override
  String get key => 'biz2';

  @override
  void onModuleRegister(ModuleContext moduleContext) {
    registerModule(flutter2.Module(), moduleContext);
    registerModule(flutter4.Module(), moduleContext);
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
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, -1),
            ).animate(secondaryAnimation),
            child: child,
          ),
        );
  }
}
