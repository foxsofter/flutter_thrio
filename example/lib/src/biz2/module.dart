import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import 'flutter2/module.dart' as flutter2;
import 'flutter4/module.dart' as flutter4;

class Module
    with
        ThrioModule,
        ModulePageBuilder,
        ModuleRouteObserver,
        NavigatorRouteObserver {
  @override
  String get key => 'biz2';

  @override
  void onModuleRegister(ModuleContext moduleContext) {
    registerModule(flutter2.Module(), moduleContext);
    registerModule(flutter4.Module(), moduleContext);
  }

  @override
  void onRouteObserverRegister(ModuleContext moduleContext) {
    registerRouteObserver(this);
  }

  @override
  void didPush(RouteSettings routeSettings) {}

  @override
  void didPop(RouteSettings routeSettings) {}

  @override
  void didPopTo(RouteSettings routeSettings) {}

  @override
  void didRemove(RouteSettings routeSettings) {}
}
