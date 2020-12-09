import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';
import 'page3.dart';
import 'page4.dart';

class Module
    with
        ThrioModule,
        ModulePageBuilder,
        ModuleRouteObserver,
        NavigatorRouteObserver {
  @override
  void onPageBuilderRegister(ModuleContext moduleContext) {
    registerPageBuilder(
      '/biz1/flutter3',
      (settings, moduleContext) => Page3(
        index: settings.index,
        params: settings.params,
      ),
    );
    registerPageBuilder(
      '/biz2/flutter4',
      (settings, moduleContext) => Page4(
        index: settings.index,
        params: settings.params,
      ),
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
