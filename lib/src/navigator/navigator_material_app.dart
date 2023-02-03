// The MIT License (MIT)
//
// Copyright (c) 2020 foxsoter
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

import '../module/module_anchor.dart';
import '../module/thrio_module.dart';
import 'navigator_home.dart';
import 'thrio_navigator_implement.dart';

class NavigatorMaterialApp extends MaterialApp {
  NavigatorMaterialApp({
    super.navigatorKey,
    final List<NavigatorObserver> navigatorObservers =
        const <NavigatorObserver>[],
    final TransitionBuilder? builder,
    super.title,
    super.home,
    super.onGenerateTitle,
    super.color,
    super.theme,
    super.darkTheme,
    super.themeMode,
    super.locale,
    super.localizationsDelegates,
    super.localeListResolutionCallback,
    super.localeResolutionCallback,
    super.supportedLocales,
    super.debugShowMaterialGrid,
    super.showPerformanceOverlay,
    super.checkerboardRasterCacheImages,
    super.checkerboardOffscreenLayers,
    super.showSemanticsDebugger,
    super.debugShowCheckedModeBanner,
    super.shortcuts,
    super.actions,
    super.restorationScopeId,
  }) : super(
          key: appKey,
          builder: (final context, final child) {
            if (builder != null) {
              return builder(context,
                  ThrioNavigatorImplement.shared().builder(context, child));
            } else {
              return ThrioNavigatorImplement.shared().builder(context, child);
            }
          },
          navigatorObservers: [...navigatorObservers],
          initialRoute: '1 /',
          routes: {'1 /': (final _) => home ?? const NavigatorHome()},
        );

  static final appKey = GlobalKey(debugLabel: 'app');

  /// Get moduleContext of root module.
  ///
  ModuleContext get moduleContext => anchor.rootModuleContext;
}
