import 'package:flutter_thrio/flutter_thrio.dart';

import 'home/module.dart' as home;

class Module with ThrioModule {
  @override
  String get key => 'flutter1';

  @override
  void onModuleRegister(final ModuleContext moduleContext) {
    registerModule(home.Module(), moduleContext);
  }
}
