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
import 'navigator_page_route.dart';
import 'thrio_navigator_implement.dart';

class NavigatorMaterialApp extends MaterialApp {
  NavigatorMaterialApp({
    super.navigatorKey,
    List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
    TransitionBuilder? builder,
    super.title,
    super.onGenerateTitle,
    this.transitionPage,
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
            builder: (context, child) => builder == null
                ? ThrioNavigatorImplement.shared().builder(context, child)
                : builder(context,
                    ThrioNavigatorImplement.shared().builder(context, child)),
            navigatorObservers: [...navigatorObservers],
            initialRoute: '1 /',
            onGenerateRoute: (settings) => settings.name == '1 /'
                ? NavigatorPageRoute(
                    pageBuilder: (_) => transitionPage ?? const NavigatorHome(),
                    settings: const RouteSettings(name: '1 /', arguments: {
                      'animated': false,
                    }))
                : null);

  static final appKey = GlobalKey(debugLabel: 'app');

  /// Transition page
  ///
  final Widget? transitionPage;

  /// Get moduleContext of root module.
  ///
  ModuleContext get moduleContext => anchor.rootModuleContext;
}
