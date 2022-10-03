import 'package:flutter_thrio/flutter_thrio.dart';

import 'page.dart' as flutter2;

class Module with ThrioModule, ModulePageBuilder, ModuleRouteTransitionsBuilder {
  @override
  String get key => 'flutter2';

  @override
  void onPageBuilderSetting(final ModuleContext moduleContext) {
    pageBuilder = (final settings) => flutter2.Page(
          url: settings.url,
          index: settings.index,
          params: settings.params,
          moduleContext: moduleContext,
        );
  }

  @override
  void onRouteTransitionsBuilderSetting(final ModuleContext moduleContext) {
    // 赋值为 null 可以清楚父级 module 设置的转场动画
    routeTransitionsBuilder = null;
  }
}
