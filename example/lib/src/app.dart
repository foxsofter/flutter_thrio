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

  @override
  void onModuleRegister() {
    ThrioModule.register(sample.Module());
  }

  @override
  void onPageRegister() {
    ThrioApp().registryDefaultPageBuilder((_, {index, params}) => DeaultPage());
  }

  @override
  void onSyncInit() {}

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      excluding: true,
      child: MaterialApp(
          home: Container(),
          builder: ThrioApp().builder(
              builder: (context, child) => Builder(
                  builder: (context) => MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaleFactor: 1,
                        ),
                        child: child,
                      )))));
}
