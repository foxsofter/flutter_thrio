import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

class Page extends StatefulWidget {
  const Page({
    Key? key,
    required this.index,
    this.params,
  }) : super(key: key);

  final int index;

  final dynamic params;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) => NavigatorPageLifecycle(
      // didAppear: (settings) {
      //   SystemChrome.setPreferredOrientations([
      //     DeviceOrientation.landscapeLeft,
      //     DeviceOrientation.landscapeRight,
      //   ]);
      // },
      // didDisappear: (settings) {
      //   SystemChrome.setPreferredOrientations([
      //     DeviceOrientation.portraitUp,
      //     // DeviceOrientation.landscapeLeft,
      //     // DeviceOrientation.landscapeRight,
      //   ]);
      // },
      child: WillPopScope(
          onWillPop: () async {
            ThrioLogger.i('page3 WillPopScope');
            return true;
          },
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
                        'flutter3: index is ${widget.index}',
                        style: const TextStyle(fontSize: 28, color: Colors.blue),
                      ),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: '/biz2/flutter4',
                        params: {
                          '1': {'2': '3'}
                        },
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'push flutter4',
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
                      onTap: () => ThrioNavigator.popTo(url: '/biz1/flutter1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'popTo flutter1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.popTo(
                        url: '/biz1/native1',
                        index: 1,
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'popTo native1',
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
                      onTap: () {
                        ThrioNavigator.notify(
                          url: '/biz1/flutter1',
                          name: 'page1Notify',
                          params: {'ss': 11},
                        );
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
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => TestPage())),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'Navigator push',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                  ]),
                ),
              ))));
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('test page'),
          leading: const IconButton(
            color: Colors.black,
            tooltip: 'back',
            icon: Icon(Icons.arrow_back_ios),
            onPressed: ThrioNavigator.pop,
          ),
        ),
        body: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: '',
                  onSaved: (val) => val,
                  validator: (val) => val == '' ? val : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.indigo)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Navigator pop',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
