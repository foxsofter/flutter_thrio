// Copyright (c) 2022 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';

part 'flutter5.context.dart';
part 'flutter5.state.dart';

class Flutter5Page extends NavigatorStatefulPage {
  const Flutter5Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter5PageState createState() => _Flutter5PageState();
}

class _Flutter5PageState extends State<Flutter5Page>
    with NavigatorPageLifecycleMixin, AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    ThrioLogger.d('page5 dispose: ${widget.settings.index}');
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('page view example',
              style: TextStyle(color: Colors.black)),
          leading: context.showPopAwareWidget(const IconButton(
            color: Colors.black,
            tooltip: 'back',
            icon: Icon(Icons.arrow_back_ios),
            onPressed: ThrioNavigator.pop,
          )),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: NavigatorPageLifecycle(
            didAppear: (final settings) {
              ThrioLogger.v('page5 didAppear -> $settings');
            },
            didDisappear: (final settings) {
              ThrioLogger.v('page5 didDisappear -> $settings');
            },
            child: NavigatorPageView(
              routeSettings: <RouteSettings>[
                NavigatorRouteSettings.settingsWith(
                    url: biz.biz1.flutter1.home.url),
                NavigatorRouteSettings.settingsWith(
                    url: biz.biz1.flutter3.url, index: 1),
                NavigatorRouteSettings.settingsWith(
                    url: biz.biz1.flutter3.url, index: 2),
                NavigatorRouteSettings.settingsWith(url: biz.biz1.flutter5.url),
              ],
            )));
  }
}
