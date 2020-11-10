import 'package:flutter/widgets.dart';
import 'package:thrio/thrio.dart';

import 'page1.dart';
import 'page2.dart';

class Module
    with
        ThrioModule,
        ModulePageBuilder,
        ModulePageObserver,
        ModuleRouteTransitionsBuilder,
        NavigatorPageObserver {
  @override
  void onPageBuilderRegister() {
    registerPageBuilder(
      '/biz1/flutter1',
      (settings) => Page1(
        index: settings.index,
        params: settings.params,
      ),
    );
    registerPageBuilder(
      '/biz2/flutter2',
      (settings) => Page2(
        index: settings.index,
        params: settings.params,
      ),
    );
  }

  @override
  void onPageObserverRegister() {
    registerPageObserver(this);
  }

  @override
  void onRouteTransitionsBuilderRegister() {
    // registerRouteTransitionsBuilder(
    //     '\/biz1\/flutter[0-9]*',
    //     (
    //       context,
    //       animation,
    //       secondaryAnimation,
    //       child,
    //     ) =>
    //         SlideTransition(
    //           transformHitTests: false,
    //           position: Tween<Offset>(
    //             begin: const Offset(0, -1),
    //             end: Offset.zero,
    //           ).animate(animation),
    //           child: SlideTransition(
    //             position: Tween<Offset>(
    //               begin: Offset.zero,
    //               end: const Offset(0, 1),
    //             ).animate(secondaryAnimation),
    //             child: child,
    //           ),
    //         ));
  }

  @override
  void didAppear(RouteSettings routeSettings) {}

  @override
  void didDisappear(RouteSettings routeSettings) {}

  @override
  void willAppear(RouteSettings routeSettings) {}

  @override
  void willDisappear(RouteSettings routeSettings) {}
}
