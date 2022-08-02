import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../../models/people.dart';

class Page extends StatefulWidget {
  const Page({
    Key? key,
    required this.moduleContext,
    required this.index,
    this.params,
  }) : super(key: key);

  final int index;

  final ModuleContext moduleContext;

  final dynamic params;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  late final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NavigatorPageNotify(
      name: 'all_page_notify',
      onPageNotify: (params) => ThrioLogger.v('flutter1 receive all page notify:$params'),
      child: NavigatorPageNotify(
          name: 'page1Notify',
          onPageNotify: (params) => ThrioLogger.v('flutter1 receive notify:$params'),
          child: Scaffold(
              appBar: PreferredSize(
                  preferredSize:
                      Platform.isIOS ? const Size.fromHeight(44) : const Size.fromHeight(56),
                  child: AppBar(
                    backgroundColor: Colors.blue,
                    title: const Text('thrio_example', style: TextStyle(color: Colors.black)),
                    leading: context.shouldCanPop(const IconButton(
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
                    Container(
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
                        if (widget.moduleContext.set('double_key_biz1_flutter1', 2.0)) {
                          final value = widget.moduleContext.get('double_key_biz1_flutter1');
                          ThrioLogger.v('double_key_biz1_flutter1 value is $value');
                        }
                        if (widget.moduleContext.set('string_key_biz1', _inputController.text)) {
                          final value = widget.moduleContext.get('string_key_biz1');
                          ThrioLogger.v('string_key_biz1 value is $value');
                        }
                        if (widget.moduleContext.set('int_key_root_module', 10000)) {
                          final value = widget.moduleContext.get('int_key_root_module');
                          ThrioLogger.v('int_key_root_module value is $value');
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
                      onTap: () => ThrioNavigator.push(
                        url: '/biz1/flutter1',
                        params: People(name: 'foxsofter', age: 100, sex: '男性'),
                        poppedResult: (params) => ThrioLogger.v('/biz1/flutter1 popped:$params'),
                      ),
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
                      onTap: () => ThrioNavigator.remove(url: '/biz1/flutter1'),
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
                      onTap: () => ThrioNavigator.push(
                        url: '/biz2/flutter2',
                        params: People(name: '大宝剑', age: 0, sex: 'x'),
                        poppedResult: (params) =>
                            ThrioLogger.v('/biz1/flutter1 poppedResult call popped:$params'),
                      ),
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
                      onTap: () => ThrioNavigator.push(
                        url: '/biz1/native1',
                        params: People(name: '大宝剑', age: 10, sex: 'x'),
                        poppedResult: (params) =>
                            ThrioLogger.v('/biz1/native1 poppedResult call params:$params'),
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
                      onTap: () => ThrioNavigator.push(url: '/biz1/swift1', params: '11221131'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: const Text(
                            'push swift1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    NavigatorPageLifecycle(
                        willAppear: (settings) {
                          ThrioLogger.v('lifecycle willAppear -> $settings');
                        },
                        didAppear: (settings) {
                          ThrioLogger.v('lifecycle didAppear -> $settings');
                        },
                        willDisappear: (settings) {
                          ThrioLogger.v('lifecycle willDisappear -> $settings');
                        },
                        didDisappear: (settings) {
                          ThrioLogger.v('lifecycle didDisappear -> $settings');
                        },
                        child: StreamBuilder<Object>(
                            stream: widget.moduleContext.on('string_key_biz1'),
                            builder: (context, snapshot) => Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(8),
                                color: Colors.grey,
                                child: Text(
                                  '${snapshot.data}',
                                  style: const TextStyle(fontSize: 22, color: Colors.black),
                                ))))
                  ]),
                ),
              ))));
}
