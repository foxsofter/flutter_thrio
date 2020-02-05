import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

import 'default_page.dart';
import 'sample/module.dart' as sample;

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({Key key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with ThrioModule {
  @override
  void initState() {
    super.initState();

    ThrioModule.register(this);
    ThrioModule.init();
  }

  // GlobalKey<NavigatorState> navigatorKey;

  @override
  void onModuleRegister() {
    ThrioModule.register(sample.Module());
  }

  @override
  void onPageRegister() {
    ThrioApp().registerDefaultPageBuilder((_, {index, params}) => DeaultPage());
  }

  @override
  void onSyncInit() {}

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: ThrioApp().build(),
        home: const SizedBox.shrink(),
      );
}
