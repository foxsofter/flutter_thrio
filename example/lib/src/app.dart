import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';
import 'module.dart';

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

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    ThrioModule.init(
      rootModule: Module(),
      moduleContext: widget._moduleContext,
    );
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: NavigatorMaterialApp(
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
          ),
        ),
      );
}
