// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter.
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

import 'package:flutter/widgets.dart';

import '../exception/thrio_exception.dart';
import '../extension/thrio_dynamic.dart';
import '../module/thrio_module.dart';
import 'navigator_material_app.dart';
import 'navigator_route_settings.dart';

mixin NavigatorPage {
  ModuleContext get moduleContext;

  RouteSettings get settings;

  /// Get parameter from params, throw ArgumentError when`key`'s value  not found .
  ///
  T getParam<T>(String key) => getValue(settings.params, key);

  /// Get parameter from params, return `defaultValue` when`key`'s value  not found .
  ///
  T getParamOrDefault<T>(String key, T defaultValue) =>
      getValueOrDefault(settings.params, key, defaultValue);

  /// Get parameter from params.
  ///
  T? getParamOrNull<T>(String key) => getValueOrNull(settings.params, key);

  List<E> getListParam<E>(String key) => getListValue<E>(settings.params, key);

  Map<K, V> getMapParam<K, V>(String key) =>
      getMapValue<K, V>(settings.params, key);

  /// Get moduleContext from current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static ModuleContext moduleContextOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) {
    final page = of(context, pageModuleContext: pageModuleContext);
    if (page != null) {
      return page.moduleContext;
    }
    // 触发兜底逻辑
    final widget = context.widget;
    if (widget is NavigatorMaterialApp) {
      return widget.moduleContext;
    }
    NavigatorMaterialApp? app;
    context.visitAncestorElements((it) {
      final widget = it.widget;
      if (widget is NavigatorMaterialApp) {
        app = widget;
        return false;
      }
      return true;
    });
    if (app == null) {
      throw ThrioException('no moduleContext on the app');
    }
    return app!.moduleContext;
  }

  /// Get params of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static dynamic paramsOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      routeSettingsOf(context, pageModuleContext: pageModuleContext).params;

  /// Get RouteSettings of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static RouteSettings routeSettingsOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      of(context, pageModuleContext: pageModuleContext)?.settings ??
      (throw ThrioException('no RouteSettings on the page'));

  /// Get url of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static String urlOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      routeSettingsOf(context, pageModuleContext: pageModuleContext).url;

  /// Get index of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static int indexOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      routeSettingsOf(context, pageModuleContext: pageModuleContext).index;

  /// Get current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static NavigatorPage? of(
    BuildContext context, {
    bool pageModuleContext = false,
  }) {
    NavigatorPage? page;
    final widget = context.widget;
    if (widget is NavigatorPage) {
      page = widget as NavigatorPage;
      if (pageModuleContext) {
        if (page.settings.isPushed) {
          return page;
        }
      } else {
        return page;
      }
      page = null;
    }
    context.visitAncestorElements((it) {
      final widget = it.widget;
      if (widget is NavigatorPage) {
        page = widget as NavigatorPage;
        if (pageModuleContext) {
          return page!.settings.isPushed;
        }
        return false;
      }
      return true;
    });
    return page;
  }

  static List<RouteSettings> routeSettingsListOf(BuildContext context) {
    final settingsList = <RouteSettings>[];
    if (context.widget is NavigatorPage) {
      final settings = (context.widget as NavigatorPage).settings;
      if (settings.isSelected != null || !settings.isBuilt) {
        settingsList.add(settings);
      }
    }
    context.visitAncestorElements((it) {
      if (it.widget is NavigatorPage) {
        final settings = (it.widget as NavigatorPage).settings;
        if (settings.isSelected != null || !settings.isBuilt) {
          // 如果已存在，则干掉并新增，因为带相同的 RouteSettings 的 NavigatorPage 会重复出现在链路上
          settingsList
            ..removeWhere((it) => it.name == settings.name)
            ..add(settings);
        }
        return settings.isBuilt;
      }
      return true;
    });
    return settingsList;
  }
}
