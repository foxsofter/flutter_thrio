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

import 'navigator_home.dart';
import 'thrio_navigator_implement.dart';

class NavigatorMaterialApp extends MaterialApp {
  NavigatorMaterialApp({
    final Key? key,
    final GlobalKey<NavigatorState>? navigatorKey,
    final List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
    final TransitionBuilder? builder,
    final String title = '',
    final Widget? home,
    final GenerateAppTitle? onGenerateTitle,
    final Color? color,
    final ThemeData? theme,
    final ThemeData? darkTheme,
    final ThemeMode themeMode = ThemeMode.system,
    final Locale? locale,
    final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    final LocaleListResolutionCallback? localeListResolutionCallback,
    final LocaleResolutionCallback? localeResolutionCallback,
    final Iterable<Locale> supportedLocales = const <Locale>[Locale('en', 'US')],
    final bool debugShowMaterialGrid = false,
    final bool showPerformanceOverlay = false,
    final bool checkerboardRasterCacheImages = false,
    final bool checkerboardOffscreenLayers = false,
    final bool showSemanticsDebugger = false,
    final bool debugShowCheckedModeBanner = true,
    final Map<LogicalKeySet, Intent>? shortcuts,
    final Map<Type, Action<Intent>>? actions,
    final String? restorationScopeId,
  }) : super(
            key: key,
            navigatorKey: navigatorKey,
            navigatorObservers: [...navigatorObservers],
            builder: (final context, final child) {
              if (builder != null) {
                return builder(context, ThrioNavigatorImplement.shared().builder(context, child));
              } else {
                return ThrioNavigatorImplement.shared().builder(context, child);
              }
            },
            title: title,
            onGenerateTitle: onGenerateTitle,
            initialRoute: '1 /',
            routes: {'1 /': (final _) => home ?? const NavigatorHome()},
            color: color,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: localizationsDelegates,
            localeListResolutionCallback: localeListResolutionCallback,
            localeResolutionCallback: localeResolutionCallback,
            supportedLocales: supportedLocales,
            debugShowMaterialGrid: debugShowMaterialGrid,
            showPerformanceOverlay: showPerformanceOverlay,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            showSemanticsDebugger: showSemanticsDebugger,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            shortcuts: shortcuts,
            actions: actions,
            restorationScopeId: restorationScopeId);
}
