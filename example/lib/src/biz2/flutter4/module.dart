import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import 'flutter4.dart';

class Module
    with
        ThrioModule,
        ModulePageBuilder,
        ModuleRouteObserver,
        NavigatorRouteObserver {
  @override
  String get key => 'flutter4';

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) => Flutter4(
          index: settings.index,
          params: settings.params,
        );
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
