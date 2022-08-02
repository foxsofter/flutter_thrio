import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../models/people.dart';

class Page extends StatefulWidget {
  const Page({
    Key? key,
    required this.url,
    required this.index,
    this.params,
  }) : super(key: key);

  final String? url;

  final int index;

  final dynamic params;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final _channel = ThrioChannel(channel: 'custom_thrio_channel');
  @override
  void initState() {
    super.initState();
    _channel.registryMethodCall('sayHello', ([arguments]) async {
      ThrioLogger.v('sayHello from native');
    });
  }

  @override
  Widget build(BuildContext context) => NavigatorPageNotify(
      name: 'page2Notify',
      onPageNotify: (params) => ThrioLogger.v('flutter2 receive notify:$params'),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('thrio_example', style: TextStyle(color: Colors.black)),
            leading: context.shouldCanPop(const IconButton(
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
                    'flutter2: index is ${widget.index}',
                    style: const TextStyle(fontSize: 28, color: Colors.blue),
                  ),
                ),
                InkWell(
                  onTap: () => ThrioNavigator.push(
                    url: '/biz1/flutter3',
                    params: {
                      '1': {'2': '3'}
                    },
                  ),
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
                  onTap: () => ThrioNavigator.remove(url: '/biz2/flutter2'),
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
                  onTap: () => ThrioNavigator.pop(params: People(name: '大宝剑', age: 0, sex: 'x')),
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
                      url: '/biz2/native2',
                      params: {
                        '1': {'2': '3'}
                      },
                      poppedResult: (params) => ThrioLogger.v('/biz1/native1 popped:$params')),
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
                        url: '/biz1/flutter1',
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
                        url: '/biz2/flutter2',
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
                    ThrioNavigator.notify(
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
              ]),
            ),
          )));
}
