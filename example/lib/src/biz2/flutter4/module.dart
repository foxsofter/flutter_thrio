import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import 'page.dart' as flutter4;

class Module with ThrioModule, ModulePageBuilder, ModuleRouteObserver, NavigatorRouteObserver {
  @override
  String get key => 'flutter4';

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) => flutter4.Page(
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
