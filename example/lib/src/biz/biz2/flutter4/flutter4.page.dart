// Copyright (c) 2022 foxsofter.
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';
import '../../types/people.dart';

part 'flutter4.state.dart';
part 'flutter4.context.dart';

class Flutter4Page extends NavigatorStatefulPage {
  const Flutter4Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter4PageState createState() => _Flutter4PageState();
}

class _Flutter4PageState extends State<Flutter4Page>
    with NavigatorPageLifecycleMixin, AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    ThrioLogger.d('page4 dispose: ${widget.settings.index}');
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
                  'flutter4: index is ${widget.settings.index}',
                  style: const TextStyle(fontSize: 28, color: Colors.blue),
                ),
              ),
              InkWell(
                onTap: () => biz.biz1.flutter1.home
                    .push(strList: <String>['1', '2', '3']),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.yellow,
                    child: const Text(
                      'push flutter1',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: biz.biz1.flutter3.remove,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.yellow,
                    child: const Text(
                      'remove flutter3',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: ThrioNavigator.pop,
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
                onTap: ThrioNavigator.popToRoot,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.yellow,
                    child: const Text(
                      'popTobiz',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () => ThrioNavigator.popTo(
                  url: '/biz/biz2/flutter2',
                ),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.yellow,
                    child: const Text(
                      'popTo flutter2',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () => ThrioNavigator.push(
                  url: '/biz1/native1',
                  params: {
                    '1': {'2': '3'}
                  },
                ),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.grey,
                    child: const Text(
                      'push native1',
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
                onTap: () async {
                  if (!await biz.biz1.flutter1.flutter1(intValue: 33)) {
                    await ThrioNavigator.push(
                        url: '/biz/biz1/flutter1/home',
                        params: {'page1Notify': {}});
                  }
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    color: Colors.grey,
                    child: const Text(
                      'open if needed and notify',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
            ]),
          ),
        ));
  }
}
