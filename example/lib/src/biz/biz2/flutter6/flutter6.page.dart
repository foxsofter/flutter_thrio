// Copyright (c) 2022 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';

part 'flutter6.context.dart';
part 'flutter6.state.dart';

class Flutter6Page extends NavigatorStatefulPage {
  const Flutter6Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter6PageState createState() => _Flutter6PageState();
}

class _Flutter6PageState extends State<Flutter6Page> {
  @override
  void dispose() {
    ThrioLogger.d('page6 dispose: ${widget.settings.index}');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('thrio_deeplink_example',
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
                'flutter6: index is ${widget.settings.index}',
                style: const TextStyle(fontSize: 28, color: Colors.blue),
              ),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.push(
                    url: 'justascheme://open/biz2/home?tab=0');
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'deeplink with one parameter',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await biz.biz1.flutter11.push();
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'push flutter11',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.push(
                    url: 'justascheme://open/biz2/home');
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'deeplink without parameter',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.push(
                    url:
                        'anotherScheme://leaderboard/home?hashId=13131973173&product=31fefq');
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'deeplink multi parameter',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.push(
                    url: 'anotherscheme://leaderboard/home?product=31fefq');
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'deeplink optional parameter',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                // final result =
                //     await ThrioNavigator.push(url: 'https://www.google.com');
                // debugPrint(result.toString());
                final s = biz.biz2.flutter6.sendEmailCode(email: 'email');
                debugPrint(s.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'deeplink with http',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.pushAndRemoveTo(
                  url: biz.biz1.flutter7.url,
                  toUrl: biz.biz1.flutter1.home.url,
                );
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'push flutter7 and remove to flutter1',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.pushSingle(
                  url: biz.biz1.flutter3.url,
                );
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'push single flutter3',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.act(
                    url: biz.biz1.flutter1.home.url,
                    action: 'getPeople?intValue=12',
                    params: <String, dynamic>{'intValue': 11});
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'act flutter1 getPeople',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result =
                    await biz.biz1.flutter1.getString(boolValue: true);
                debugPrint(result);
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'act flutter1 get void',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
          ]),
        ),
      ));
}
