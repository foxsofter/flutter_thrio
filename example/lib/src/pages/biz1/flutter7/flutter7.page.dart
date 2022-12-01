// Copyright (c) 2022 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';

part 'flutter7.context.dart';
part 'flutter7.state.dart';

class Flutter7Page extends NavigatorStatefulPage {
  const Flutter7Page({
    super.key,
    required super.moduleContext,
    super.params,
    super.url,
    super.index,
  });

  @override
  _Flutter7PageState createState() => _Flutter7PageState();
}

class _Flutter7PageState extends State<Flutter7Page> with SingleTickerProviderStateMixin {
  late final controller = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    ThrioLogger.d('page7 dispose');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('TabBarView example', style: TextStyle(color: Colors.black)),
        leading: context.shouldCanPop(const IconButton(
          color: Colors.black,
          tooltip: 'back',
          icon: Icon(Icons.arrow_back_ios),
          onPressed: ThrioNavigator.pop,
        )),
        bottom: TabBar(
          controller: controller,
          indicatorColor: Colors.black,
          tabs: const <Tab>[
            Tab(text: 'flutter1'),
            Tab(text: 'flutter5'),
            Tab(text: 'flutter2'),
            Tab(text: 'flutter4'),
          ],
        ),
      ),
      body: NavigatorPageLifecycle(
          url: root.biz1.flutter1.home.url,
          willAppear: (final settings) {
            ThrioLogger.v('page7 willAppear -> $settings');
          },
          didAppear: (final settings) {
            ThrioLogger.v('page7 didAppear -> $settings');
          },
          willDisappear: (final settings) {
            ThrioLogger.v('page7 willDisappear -> $settings');
          },
          didDisappear: (final settings) {
            ThrioLogger.v('page7 didDisappear -> $settings');
          },
          child: NavigatorPageLifecycle(
              url: root.biz2.flutter2.url,
              willAppear: (final settings) {
                ThrioLogger.v('page7 willAppear -> $settings');
              },
              didAppear: (final settings) {
                ThrioLogger.v('page7 didAppear -> $settings');
              },
              willDisappear: (final settings) {
                ThrioLogger.v('page7 willDisappear -> $settings');
              },
              didDisappear: (final settings) {
                ThrioLogger.v('page7 didDisappear -> $settings');
              },
              child: NavigatorTabBarView(
                controller: controller,
                routeSettings: <RouteSettings>[
                  NavigatorRouteSettings.settingsWith(url: root.biz1.flutter1.home.url, index: 1),
                  NavigatorRouteSettings.settingsWith(url: root.biz1.flutter5.url, index: 1),
                  NavigatorRouteSettings.settingsWith(url: root.biz2.flutter2.url, index: 1),
                  NavigatorRouteSettings.settingsWith(url: root.biz2.flutter4.url, index: 1),
                ],
              ))));
}
