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
    super.params,
    super.url,
    super.index,
  });

  @override
  _Flutter4PageState createState() => _Flutter4PageState();
}

class _Flutter4PageState extends State<Flutter6Page> {
  @override
  void dispose() {
    ThrioLogger.d('page6 dispose');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('thrio_deeplink_example', style: TextStyle(color: Colors.black)),
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
                'flutter6: index is ${widget.index}',
                style: const TextStyle(fontSize: 28, color: Colors.blue),
              ),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.push(url: 'justascheme://open/home?tab=0');
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'test deeplink one queryParams',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
            InkWell(
              onTap: () async {
                final result = await ThrioNavigator.push(
                    url: 'anotherScheme://leaderboard/home?hashId=13131973173&product=good');
                debugPrint(result.toString());
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  color: Colors.yellow,
                  child: const Text(
                    'test deeplink multi queryParams',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ),
          ]),
        ),
      ));
}
