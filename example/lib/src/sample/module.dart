import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import 'module1/module.dart' as module1;
import 'module2/module.dart' as module2;

class Module with ThrioModule, NavigatorRouteObserver {
  @override
  void onModuleRegister() {
    registerModule(module1.Module());
    registerModule(module2.Module());
    registerRouteObserver(this);
  }

  @override
  void didPop(
    RouteSettings routeSettings,
    RouteSettings previousRouteSettings,
  ) {}

  @override
  void didPopTo(
    RouteSettings routeSettings,
    RouteSettings previousRouteSettings,
  ) {}

  @override
  void didPush(
    RouteSettings routeSettings,
    RouteSettings previousRouteSettings,
  ) {}

  @override
  void didRemove(
    RouteSettings routeSettings,
    RouteSettings previousRouteSettings,
  ) {}
}
