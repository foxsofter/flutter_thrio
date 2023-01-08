// Copyright (c) 2022 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';
import '../../types/people.dart';

part 'flutter3.context.dart';
part 'flutter3.state.dart';

class Flutter3Page extends NavigatorStatefulPage {
  const Flutter3Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter3PageState createState() => _Flutter3PageState();
}

class _Flutter3PageState extends State<Flutter3Page>
    with NavigatorPageLifecycleMixin, AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    ThrioLogger.d('page3 dispose: ${widget.settings.index}');

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return WillPopScope(
        onWillPop: () async {
          final r = await ThrioNavigator.push(url: '/biz/biz2/flutter2');
          ThrioLogger.i('page3 WillPopScope: $r');
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('thrio_example',
                style: TextStyle(color: Colors.black)),
            leading: context.showPopAwareWidget(const IconButton(
              color: Colors.black,
              tooltip: 'back',
              icon: Icon(Icons.arrow_back_ios),
              onPressed: ThrioNavigator.maybePop,
            )),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                alignment: AlignmentDirectional.center,
                child: Text(
                  'flutter3: index is ${widget.settings.index}',
                  style: const TextStyle(fontSize: 28, color: Colors.blue),
                ),
              ),
              InkWell(
                onTap: () => biz.biz2.flutter4
                    .push(people: People(age: 10, name: 'goodman', sex: '女')),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.yellow,
                    child: const Text(
                      'push flutter4',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: biz.biz2.flutter2.remove,
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.yellow,
                    child: const Text(
                      'remove flutter2',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () => ThrioNavigator.pop(params: 'goodman'),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.yellow,
                    child: const Text(
                      'pop',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: biz.biz1.flutter1.home.popTo,
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.yellow,
                    child: const Text(
                      'popTo flutter1',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () => ThrioNavigator.popToFirst(url: '/biz1/native1'),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
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
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.grey,
                    child: const Text(
                      'push native1',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () => ThrioNavigator.remove(url: '/biz1/native1'),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.grey,
                    child: const Text(
                      'pop native1',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () async => biz.biz1.flutter1.flutter1(intValue: 9),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.grey,
                    child: const Text(
                      'notify flutter1',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (final context) => const TestPage())),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.yellow,
                    child: const Text(
                      'Navigator push',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              InkWell(
                onTap: biz.biz1.flutter7.push,
                child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    color: Colors.yellow,
                    child: const Text(
                      'push flutter7',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(Colors.indigo)),
                  onPressed: () {
                    final r = biz.biz2.flutter8.push();
                    ThrioLogger.v(r.toString());
                  },
                  child: const Text(
                    'push flutter8',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ]),
          ),
        ));
  }

  @override
  void didAppear(final RouteSettings settings) {
    ThrioLogger.d('flutter3 didAppear: $settings');
  }

  @override
  void didDisappear(final RouteSettings settings) {
    ThrioLogger.d('flutter3 didDisappear: $settings');
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(final BuildContext context) => Scaffold(
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
                  onSaved: (final val) => val,
                  validator: (final val) => val == '' ? val : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(Colors.indigo)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Navigator pop',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(Colors.indigo)),
                  onPressed: () {
                    final mctx = NavigatorPage.moduleContextOf(context);
                    ThrioLogger.v(mctx.toString());
                  },
                  child: const Text(
                    'Get ModuleContext',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
