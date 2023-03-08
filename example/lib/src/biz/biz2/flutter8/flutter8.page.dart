// Copyright (c) 2023 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';

part 'flutter8.context.dart';
part 'flutter8.state.dart';

class Flutter8Page extends NavigatorStatefulPage {
  const Flutter8Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter8PageState createState() => _Flutter8PageState();
}

class _Flutter8PageState extends State<Flutter8Page>
    with NavigatorPageLifecycleMixin, AutomaticKeepAliveClientMixin {
  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('thrio_build_example',
            style: TextStyle(color: Colors.black)),
        leading: context.showPopAwareWidget(const IconButton(
          color: Colors.black,
          tooltip: 'back',
          icon: Icon(Icons.arrow_back_ios),
          onPressed: ThrioNavigator.pop,
        )),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SizedBox(
          height: 400,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 200,
                child: ThrioNavigator.build(url: biz.biz2.flutter10.url) ??
                    const Text('url not found'),
              ),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
