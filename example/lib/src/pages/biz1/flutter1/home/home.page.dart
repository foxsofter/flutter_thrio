// Copyright (c) 2022 foxsofter.
//

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../../route.dart';
import '../../../types/people.dart';
import '../notifies/flutter1_notify.dart';

part 'home.state.dart';
part 'home.context.dart';

class HomePage extends NavigatorStatefulPage {
  const HomePage({
    super.key,
    required super.moduleContext,
    super.params,
    super.url,
    super.index,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    ThrioLogger.d('page1 dispose');
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => NavigatorRoutePush(
        url: root.biz2.flutter2.url,
        onPush: (final settings, {final animated = true}) async {
          // root.biz1.flutter1.home.replace(newUrl: root.biz2.flutter2.url);
          ThrioLogger.d('page2 onPush');
          return NavigatorRoutePushHandleType.none;
        },
        child: NavigatorPageNotify(
            name: 'all_page_notify',
            onPageNotify: (final params) =>
                ThrioLogger.v('flutter1 receive all page notify:$params'),
            child: Flutter1Notify(
                onNotify: ({final intValue = 0}) =>
                    ThrioLogger.v('flutter1 receive notify:$intValue'),
                child: Scaffold(
                    appBar: PreferredSize(
                        preferredSize:
                            Platform.isIOS ? const Size.fromHeight(44) : const Size.fromHeight(56),
                        child: AppBar(
                          backgroundColor: Colors.blue,
                          title: const Text('thrio_example', style: TextStyle(color: Colors.black)),
                          leading: context.showPopAwareWidget(const IconButton(
                            color: Colors.black,
                            tooltip: 'back',
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: ThrioNavigator.pop,
                          )),
                          systemOverlayStyle: SystemUiOverlayStyle.dark,
                        )),
                    body: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        child: Column(children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 20),
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              'flutter1: index is ${widget.index}',
                              style: const TextStyle(fontSize: 28, color: Colors.blue),
                            ),
                          ),
                          SizedBox(
                              height: 25,
                              width: 100,
                              child: TextField(
                                  controller: _inputController,
                                  textInputAction: TextInputAction.search,
                                  // onSubmitted: onSubmitted,
                                  decoration: const InputDecoration(
                                    hintText: 'hintText',
                                    contentPadding: EdgeInsets.only(bottom: 12),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: print)),
                          InkWell(
                            onTap: () {
                              if (widget.moduleContext.setStringKeyBiz1(_inputController.text)) {
                                final value = widget.moduleContext.stringKeyBiz1;
                                ThrioLogger.v('stringKeyBiz1 value is $value');
                              }
                              if (widget.moduleContext.setIntKeyRootModule(10000)) {
                                final value = widget.moduleContext.intKeyRootModule;
                                ThrioLogger.v('intKeyRootModule value is $value');
                              }

                              final value = widget.moduleContext.get('people_from_native');
                              ThrioLogger.v('people_from_native value is $value');
                            },
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.yellow,
                                child: const Text(
                                  'set module context',
                                  style: TextStyle(fontSize: 22, color: Colors.black),
                                )),
                          ),
                          InkWell(
                            onTap: () async {
                              final params = await root.biz1.flutter1.home.push(
                                params: People(name: 'foxsofter', age: 100, sex: '男性'),
                              );
                              ThrioLogger.v('/biz1/flutter1 popped:$params');
                            },
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
                            onTap: root.biz1.flutter1.home.remove,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.yellow,
                                child: const Text(
                                  'remove flutter1',
                                  style: TextStyle(fontSize: 22, color: Colors.black),
                                )),
                          ),
                          InkWell(
                            onTap: () async {
                              final params = await root.biz2.flutter2.push(
                                params: People(name: '大宝剑', age: 0, sex: 'x'),
                              );
                              ThrioLogger.v(
                                  '${root.biz2.flutter2.url} poppedResult call popped:$params');
                            },
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.yellow,
                                child: const Text(
                                  'push flutter2',
                                  style: TextStyle(fontSize: 22, color: Colors.black),
                                )),
                          ),
                          InkWell(
                            onTap: () =>
                                ThrioNavigator.pop(params: People(name: '大宝剑', age: 0, sex: 'x')),
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
                                url: '/biz1/native1',
                                params: People(name: '大宝剑', age: 10, sex: 'x'),
                              );
                              ThrioLogger.v('/biz1/native1 poppedResult call params:$params');
                            },
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
                            onTap: () => ThrioNavigator.notify(
                              url: '/biz1/native1',
                              name: 'aaa',
                              params: {
                                '1': {'2': '3'}
                              },
                            ),
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.grey,
                                child: const Text(
                                  'notify native1',
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
                                  'remove native1',
                                  style: TextStyle(fontSize: 22, color: Colors.black),
                                )),
                          ),
                          InkWell(
                            onTap: () => ThrioNavigator.replace(
                              url: root.biz1.flutter1.url,
                              newUrl: root.biz2.flutter2.url,
                            ),
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.grey,
                                child: const Text(
                                  'replace flutter2',
                                  style: TextStyle(fontSize: 22, color: Colors.black),
                                )),
                          ),
                          InkWell(
                            onTap: () async {
                              final canPop = await ThrioNavigator.canPop();
                              debugPrint('canPop: $canPop');
                            },
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.grey,
                                child: const Text(
                                  'canPop',
                                  style: TextStyle(fontSize: 22, color: Colors.black),
                                )),
                          ),
                          NavigatorPageLifecycle(
                              willAppear: (final settings) {
                                ThrioLogger.v('home willAppear -> $settings');
                              },
                              didAppear: (final settings) {
                                ThrioLogger.v('home  didAppear -> $settings');
                              },
                              willDisappear: (final settings) {
                                ThrioLogger.v('home  willDisappear -> $settings');
                              },
                              didDisappear: (final settings) {
                                ThrioLogger.v('home  didDisappear -> $settings');
                              },
                              child: StreamBuilder<Object>(
                                  stream: widget.moduleContext.on('stringKeyBiz1'),
                                  builder: (final context, final snapshot) => Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.all(8),
                                      color: Colors.grey,
                                      child: Text(
                                        '${snapshot.data}',
                                        style: const TextStyle(fontSize: 22, color: Colors.black),
                                      ))))
                        ]),
                      ),
                    )))),
      );
}
