import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import 'page.dart' as flutter3;

class Module with ThrioModule, ModulePageBuilder, ModuleRouteObserver, NavigatorRouteObserver {
  @override
  String get key => 'flutter3';

  @override
  void onPageBuilderSetting(final ModuleContext moduleContext) {
    pageBuilder = (final settings) => flutter3.Page(
          index: settings.index,
          params: settings.params,
        );
  }

  @override
  void onRouteObserverRegister(final ModuleContext moduleContext) {
    registerRouteObserver(this);
  }

  @override
  void didPush(final RouteSettings routeSettings) {}

  @override
  void didPop(final RouteSettings routeSettings) {}

  @override
  void didPopTo(final RouteSettings routeSettings) {}

  @override
  void didRemove(final RouteSettings routeSettings) {}
}
