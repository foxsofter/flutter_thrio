// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

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
