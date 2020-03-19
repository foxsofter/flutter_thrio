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
  @override
  void initState() {
    super.initState();

    if (mounted) {}
  }

  @override
  Widget build(BuildContext context) => NavigatorPageNotify(
      name: 'page1Notify',
      onPageNotify: (params) =>
          ThrioLogger.v('flutter1 receive notify:$params'),
      child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.blue,
            textTheme: TextTheme(title: TextStyle(color: Colors.black)),
            title: const Text('thrio_example'),
            leading: IconButton(
              color: Colors.black,
              tooltip: 'back',
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: ThrioNavigator.pop,
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'flutter1: index is ${widget.index}',
                        style: TextStyle(fontSize: 28, color: Colors.blue),
                      ),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: 'biz1/flutter1',
                        params: {
                          '1': {'2': '3'}
                        },
                        poppedResult: (params) =>
                            ThrioLogger.v('biz1/flutter1 popped:$params'),
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'push flutter1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.remove(url: 'biz1/flutter1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'remove flutter1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: 'biz2/flutter2',
                        params: {
                          '1': {'2': '3'}
                        },
                        poppedResult: (params) => ThrioLogger.v(
                            'biz1/flutter1 poppedResult call popped:$params'),
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'push flutter2',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () =>
                          ThrioNavigator.pop(params: 'popped flutter1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'pop',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: 'native1',
                        params: {
                          '1': {'2': '3'}
                        },
                        poppedResult: (params) => ThrioLogger.v(
                            'biz1/flutter1 poppedResult call params:$params'),
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: Text(
                            'push native1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.notify(
                        url: 'native1',
                        name: 'aaa',
                        params: {
                          '1': {'2': '3'}
                        },
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: Text(
                            'notify native1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.remove(url: 'native1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: Text(
                            'remove native1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                  ]),
            ),
          )));
}
