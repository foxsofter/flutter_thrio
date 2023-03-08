// Copyright (c) 2022 foxsofter.
//

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';

part 'flutter7.context.dart';
part 'flutter7.state.dart';

class Flutter7Page extends NavigatorStatefulPage {
  const Flutter7Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter7PageState createState() => _Flutter7PageState();
}

class _Flutter7PageState extends State<Flutter7Page>
    with
        SingleTickerProviderStateMixin,
        NavigatorPageLifecycleMixin,
        AutomaticKeepAliveClientMixin {
  late final controller = TabController(
      initialIndex: Random.secure().nextInt(4), length: 5, vsync: this);

  @override
  void dispose() {
    ThrioLogger.d('page7 dispose: ${widget.settings.index}');
    super.dispose();
  }

  @override
  void didAppear(final RouteSettings routeSettings) {
    super.didAppear(routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    super.didDisappear(routeSettings);
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('TabBarView example',
              style: TextStyle(color: Colors.black)),
          leading: context.showPopAwareWidget(const IconButton(
            color: Colors.black,
            tooltip: 'back',
            icon: Icon(Icons.arrow_back_ios),
            onPressed: ThrioNavigator.pop,
          )),
          bottom: TabBar(
            controller: controller,
            indicatorColor: Colors.white,
            tabs: const <Tab>[
              Tab(text: 'flutter5'),
              Tab(text: 'flutter1'),
              Tab(text: 'flutter2'),
              Tab(text: 'flutter3'),
              Tab(text: 'flutter8'),
            ],
          ),
        ),
        body: NavigatorPageLifecycle(
            didAppear: (final settings) {
              ThrioLogger.v('page7 didAppear -> $settings');
            },
            didDisappear: (final settings) {
              ThrioLogger.v('page7 didDisappear -> $settings');
            },
            child: NavigatorTabBarView(
              controller: controller,
              routeSettings: <RouteSettings>[
                NavigatorRouteSettings.settingsWith(url: biz.biz2.flutter8.url),
                NavigatorRouteSettings.settingsWith(
                    url: biz.biz1.flutter1.home.url),
                NavigatorRouteSettings.settingsWith(url: biz.biz1.flutter7.url),
                NavigatorRouteSettings.settingsWith(url: biz.biz2.flutter2.url),
                NavigatorRouteSettings.settingsWith(url: biz.biz1.flutter3.url),
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;
}
