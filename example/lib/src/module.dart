import 'package:flutter_thrio/flutter_thrio.dart';

import 'biz1/module.dart' as biz1;
import 'biz2/module.dart' as biz2;
import 'models/people.dart';

class Module with ThrioModule, ModuleParamScheme, ModuleJsonSerializer, ModuleJsonDeserializer {
  @override
  void onModuleRegister(final ModuleContext moduleContext) {
    registerModule(biz1.Module(), moduleContext);
    registerModule(biz2.Module(), moduleContext);
  }

  @override
  void onParamSchemeRegister(final ModuleContext moduleContext) {
    registerParamScheme('int_key_root_module');
    registerParamScheme('people_key_root_module');
  }

  @override
  void onModuleInit(final ModuleContext moduleContext) {
    navigatorLogEnabled = true;
  }

  @override
  void onJsonSerializerRegister(final ModuleContext moduleContext) {
    registerJsonSerializer<People>((final instance) => instance<People>().toJson());
  }

  @override
  void onJsonDeserializerRegister(final ModuleContext moduleContext) {
    registerJsonDeserializer(People.fromJson);
  }
}
