// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'thrio_navigator_implement.dart';

class NavigatorHotRestartButton extends StatefulWidget {
  const NavigatorHotRestartButton({
    super.key,
    this.style,
  });

  final ButtonStyle? style;

  @override
  State<NavigatorHotRestartButton> createState() =>
      _NavigatorHotRestartButtonState();
}

class _NavigatorHotRestartButtonState extends State<NavigatorHotRestartButton> {
  final _initAppear = AsyncMemoizer<void>();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _initAppear
          .runOnce(() => Future.delayed(const Duration(milliseconds: 1000), () {
                final routes =
                    ThrioNavigatorImplement.shared().allFlutterRoutes();
                if (routes.length < 2) {
                  ThrioNavigatorImplement.shared().hotRestart();
                }
              }));
    }
  }

  @override
  Widget build(final BuildContext context) => ElevatedButton(
        style: widget.style,
        onPressed: () => ThrioNavigatorImplement.shared().hotRestart(),
        child: const Center(child: Text('hot restart')),
      );
}
