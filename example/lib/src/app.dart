import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

import 'default_page.dart';
import 'sample/module.dart' as sample;

void main() => runApp(const MainApp());
void biz1() => runApp(const MainApp(entrypoint: 'biz1'));
void biz2() => runApp(const MainApp(entrypoint: 'biz2'));

class MainApp extends StatefulWidget {
  const MainApp({Key key, String entrypoint = ''})
      : _entrypoint = entrypoint,
        super(key: key);

  final String _entrypoint;

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with ThrioModule {
  @override
  void initState() {
    super.initState();

    registerModule(this);
    initModule();
  }

  @override
  void onModuleRegister() {
    registerModule(sample.Module());
  }

  @override
  void onPageRegister() {
    registerDefaultPageBuilder((_, {index, params}) => DeaultPage());
  }

  @override
  void onModuleInit() {}

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: ThrioNavigator.builder(entrypoint: widget._entrypoint),
        home: NavigatorHome(),
      );
}
