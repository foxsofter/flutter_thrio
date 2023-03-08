// Copyright (c) 2022 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';
import '../../types/people.dart';

part 'flutter2.state.dart';
part 'flutter2.context.dart';

class Flutter2Page extends NavigatorStatefulPage {
  const Flutter2Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter2PageState createState() => _Flutter2PageState();
}

class _Flutter2PageState extends State<Flutter2Page>
    with NavigatorPageLifecycleMixin, AutomaticKeepAliveClientMixin {
  final _channel = ThrioChannel(channel: 'custom_thrio_channel');
  @override
  void initState() {
    super.initState();
    _channel.registryMethodCall('sayHello', ([final arguments]) async {
      ThrioLogger.v('sayHello from native');
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    ThrioLogger.d('page2 dispose: ${widget.settings.index}');
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
    return NavigatorPageNotify(
        name: 'page2Notify',
        onPageNotify: (final params) =>
            ThrioLogger.v('flutter2 receive notify:$params'),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text('thrio_example',
                  style: TextStyle(color: Colors.black)),
              leading: context.showPopAwareWidget(const IconButton(
                color: Colors.black,
                tooltip: 'back',
                icon: Icon(Icons.arrow_back_ios),
                onPressed: ThrioNavigator.pop,
              )),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(24),
                child: Column(children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      'flutter2: index is ${widget.settings.index}',
                      style: const TextStyle(fontSize: 28, color: Colors.blue),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final r = await ThrioNavigator.push(
                        url: '/biz/biz1/flutter3',
                        params: {
                          '1': {'2': '3'}
                        },
                      );
                      ThrioLogger.v('flutter3 return: $r');
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.yellow,
                        child: const Text(
                          'push flutter3',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () =>
                        ThrioNavigator.remove(url: '/biz/biz2/flutter2'),
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.yellow,
                        child: const Text(
                          'remove flutter2',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () => ThrioNavigator.pop(
                        params: People(name: '大宝剑', age: 0, sex: 'x')),
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.yellow,
                        child: const Text(
                          'pop',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () async {
                      final params = await ThrioNavigator.push(
                          url: '/biz2/native2',
                          params: {
                            '1': {'2': '3'}
                          });
                      ThrioLogger.v('/biz1/native1 popped:$params');
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'push native2',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () => ThrioNavigator.remove(url: '/biz1/native1'),
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'pop native1',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      ThrioNavigator.notify(
                          url: '/biz/biz1/flutter1/home',
                          name: 'page1Notify',
                          params: People(name: '大宝剑', age: 1, sex: 'x'));
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'notify flutter1',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      ThrioNavigator.notify(
                          url: '/biz/biz2/flutter2',
                          name: 'page2Notify',
                          params: People(name: '大宝剑', age: 2, sex: 'x'));
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'notify flutter2',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      ThrioNavigator.notifyAll(
                          name: 'all_page_notify_from_flutter2',
                          params: People(name: '大宝剑', age: 2, sex: 'x'));
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'notify all',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      ThrioNavigator.pushReplace(
                          url: biz.biz1.flutter1.home.url);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'pushReplace flutter1',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: biz.biz1.flutter5.push,
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'push flutter5',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                  InkWell(
                    onTap: biz.biz2.flutter6.push,
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          'push flutter6',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )),
                  ),
                ]),
              ),
            )));
  }
}
