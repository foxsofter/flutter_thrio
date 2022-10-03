import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter2/module.dart' as flutter2;
import 'flutter4/module.dart' as flutter4;

class Module with ThrioModule, ModulePageBuilder, ModuleRouteTransitionsBuilder {
  @override
  String get key => 'biz2';

  @override
  void onModuleRegister(final ModuleContext moduleContext) {
    registerModule(flutter2.Module(), moduleContext);
    registerModule(flutter4.Module(), moduleContext);
  }
}
