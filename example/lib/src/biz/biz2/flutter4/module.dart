// Copyright (c) 2024 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter4.page.dart';

class Module with ThrioModule, ModulePageBuilder {
  @override
  String get key => 'flutter4';

  @override
  void onPageBuilderSetting(final ModuleContext moduleContext) =>
      pageBuilder = (settings) => Flutter4Page(
            moduleContext: moduleContext,
            settings: settings,
          );
}
