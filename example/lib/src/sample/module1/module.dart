import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import 'page1.dart';
import 'page2.dart';

class Module with ThrioModule, NavigatorPageObserver {
  @override
  void onPageRegister() {
    registerPageBuilder(
      'biz1/flutter1',
      (settings) => Page1(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'biz2/flutter2',
      (settings) => Page2(index: settings.index, params: settings.params),
    );

    registerPageObserver(this);
  }

  @override
  void onCreate(RouteSettings routeSettings) {}

  @override
  void didAppear(RouteSettings routeSettings) {}

  @override
  void didDisappear(RouteSettings routeSettings) {}

  @override
  void willAppear(RouteSettings routeSettings) {}

  @override
  void willDisappear(RouteSettings routeSettings) {}
}
