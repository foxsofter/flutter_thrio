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

// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/widgets.dart';

import '../navigator/navigator_route.dart';
import '../navigator/navigator_route_settings.dart';
import '../navigator/navigator_widget.dart';
import '../navigator/thrio_navigator_implement.dart';

extension ThrioBuildContext on BuildContext {
  /// Get widget state by ancestorStateOfType method.
  ///
  /// Throw `Exception` if the `state.runtimeType` is not a T.
  ///
  T stateOf<T extends State<StatefulWidget>>() {
    final state = findAncestorStateOfType<T>();
    if (state != null) {
      return state;
    }
    throw Exception('${state.runtimeType} is not a $T');
  }

  /// Get widget state by ancestorStateOfType method.
  ///
  T? tryStateOf<T extends State<StatefulWidget>>() {
    final state = findAncestorStateOfType<T>();
    if (state != null) {
      return state;
    }
    return null;
  }

  /// Use `shouldCanPop` to determine whether to display the back arrow.
  ///
  /// ```dart
  /// AppBar(
  ///   brightness: Brightness.light,
  ///   backgroundColor: Colors.blue,
  ///   title: const Text(
  ///     'thrio_example',
  ///     style: TextStyle(color: Colors.black)),
  ///   leading: context.shouldCanPop(const IconButton(
  ///     color: Colors.black,
  ///     tooltip: 'back',
  ///     icon: Icon(Icons.arrow_back_ios),
  ///     onPressed: ThrioNavigator.pop,
  ///   )),
  /// ))
  /// ```
  ///
  Widget showPopAwareWidget(
    Widget trueWidget, {
    Widget falseWidget = const SizedBox(),
    void Function(bool)? canPopResult,
  }) =>
      FutureBuilder<bool>(
          future: _isInitialRoute(),
          builder: (context, snapshot) {
            canPopResult?.call(snapshot.data != true);
            if (snapshot.data == true) {
              return falseWidget;
            } else {
              return trueWidget;
            }
          });

  Future<bool> _isInitialRoute() {
    final state = stateOf<NavigatorWidgetState>();
    final route = state.history.last;
    return route is NavigatorRoute
        ? ThrioNavigatorImplement.shared().isInitialRoute(
            url: route.settings.url,
            index: route.settings.index,
          )
        : Future<bool>.value(false);
  }
}
