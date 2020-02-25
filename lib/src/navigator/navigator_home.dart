// Copyright (c) 2019/2/25, 11:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/material.dart';
import 'thrio_navigator.dart';

class NavigatorHome extends StatefulWidget {
  @override
  _NavigatorHomeState createState() => _NavigatorHomeState();
}

class _NavigatorHomeState extends State<NavigatorHome> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.blue,
        textTheme: TextTheme(title: TextStyle(color: Colors.white)),
        title: const Text('thrio_example'),
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
                        '如果你看到这个页面，点击hot restart按钮',
                        style: TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    ),
                    InkWell(
                      onTap: ThrioNavigator.hotRestart,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'hot restart',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                  ]))));
}
