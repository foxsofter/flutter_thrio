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
import 'package:flutter/services.dart';

import 'thrio_navigator_implement.dart';

class NavigatorHome extends StatefulWidget {
  const NavigatorHome({this.showRestartButton = false});

  final bool showRestartButton;

  @override
  _NavigatorHomeState createState() => _NavigatorHomeState();
}

class _NavigatorHomeState extends State<NavigatorHome> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('...', style: TextStyle(color: Colors.blue)),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
          const SizedBox(width: 60, height: 60, child: CircularProgressIndicator()),
          if (widget.showRestartButton)
            InkWell(
              onTap: () => ThrioNavigatorImplement.shared().hotRestart(),
              child: Container(
                  padding: const EdgeInsets.only(top: 160),
                  child: const Text(
                    'hot restart',
                    style: TextStyle(
                        fontSize: 22, color: Colors.blue, decoration: TextDecoration.underline),
                  )),
            ),
        ]))),
      );
}
