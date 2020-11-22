import 'package:thrio/thrio.dart';

import 'module1/module.dart' as module1;
import 'module2/module.dart' as module2;

class Module with ThrioModule {
  @override
  void onModuleRegister(ModuleContext moduleContext) {
    registerModule(moduleContext, module1.Module());
    registerModule(moduleContext, module2.Module());
  }
}
