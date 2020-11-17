import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

import 'sample/module.dart' as sample;

void main() => runApp(MainApp());
void biz1() => runApp(MainApp(entrypoint: 'biz1'));
void biz2() => runApp(MainApp(entrypoint: 'biz2'));

class MainApp extends StatefulWidget {
  MainApp({Key key, String entrypoint = 'main'})
      : _moduleContext = ModuleContext(entrypoint: entrypoint),
        super(key: key);

  final ModuleContext _moduleContext;

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with ThrioModule {
  @override
  void initState() {
    super.initState();
    registerModule(widget._moduleContext, this);
    initModule(widget._moduleContext);
  }

  @override
  void onModuleRegister(ModuleContext context) {
    registerModule(context, sample.Module());
  }

  @override
  void onModuleInit(ModuleContext context) {
    navigatorLogEnabled = true;
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: NavigatorMaterialApp(
          showPerformanceOverlay: true,
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
          ),
        ),
      );
}
