import 'package:flutter/material.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import 'module.dart';

void main() => runApp(const MainApp());
void biz1() => runApp(const MainApp(entrypoint: 'biz1'));
void biz2() => runApp(const MainApp(entrypoint: 'biz2'));

class MainApp extends StatefulWidget {
  const MainApp({super.key, final String entrypoint = 'main'})
      : _entrypoint = entrypoint;

  final String _entrypoint;

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    ThrioModule.init(Module(), entrypoint: widget._entrypoint,
        onModuleInitStart: (final url) {
      ThrioLogger.i('module start init: $url');
    });
  }

  @override
  Widget build(final BuildContext context) => NavigatorMaterialApp(
        transitionPage: const NavigatorHome(showRestartButton: true),
        builder: (final context, final child) => Container(
          child: child,
        ),
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          }),
        ),
      );
}
