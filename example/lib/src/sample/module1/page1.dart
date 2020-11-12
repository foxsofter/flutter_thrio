import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

class Page1 extends StatefulWidget {
  const Page1({
    Key key,
    this.index,
    this.params,
  }) : super(key: key);

  final int index;

  final dynamic params;

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  TextEditingController _inputController;
  @override
  void initState() {
    super.initState();

    if (mounted) {
      _inputController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NavigatorPageNotify(
      name: 'page1Notify',
      initialParams:
          widget.params == null ? null : widget.params['page1Notify'],
      onPageNotify: (params) =>
          ThrioLogger.v('flutter1 receive notify:$params'),
      child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Platform.isIOS
                  ? const Size.fromHeight(44)
                  : const Size.fromHeight(56),
              child: AppBar(
                brightness: Brightness.light,
                backgroundColor: Colors.blue,
                title: const Text('thrio_example',
                    style: TextStyle(color: Colors.black)),
                leading: const IconButton(
                  color: Colors.black,
                  tooltip: 'back',
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: ThrioNavigator.pop,
                ),
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
                  onTap: () => ThrioNavigator.push(
                    url: '/biz1/flutter1',
                    params: {
                      '1': {'2': '3'}
                    },
                    poppedResult: (params) =>
                        ThrioLogger.v('/biz1/flutter1 popped:$params'),
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
                    params: {
                      '1': {'2': '3'}
                    },
                    poppedResult: (params) => ThrioLogger.v(
                        '/biz1/flutter1 poppedResult call popped:$params'),
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
                  onTap: () => ThrioNavigator.pop(params: 'popped flutter1'),
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
                    params: {
                      '1': {'2': '3'}
                    },
                    poppedResult: (params) => ThrioLogger.v(
                        '/biz1/flutter1 poppedResult call params:$params'),
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
                  onTap: () => ThrioNavigator.push(url: '/biz1/swift1'),
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
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        color: Colors.grey,
                        child: const Text(
                          '',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        )))
              ]),
            ),
          )));
}
