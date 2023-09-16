// The MIT License (MIT)
//
// Copyright (c) 2020 foxsofter
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

// ignore_for_file: avoid_as

import 'package:flutter/widgets.dart';

import '../navigator/navigator_page_observer.dart';
import '../navigator/navigator_route.dart';
import '../navigator/navigator_route_observer.dart';
import '../navigator/navigator_route_settings.dart';
import '../navigator/navigator_types.dart';
import '../navigator/navigator_url_template.dart';
import '../navigator/thrio_navigator_implement.dart';
import '../registry/registry_order_map.dart';
import '../registry/registry_set.dart';
import '../registry/registry_set_map.dart';
import 'module_json_deserializer.dart';
import 'module_json_serializer.dart';
import 'module_page_builder.dart';
import 'module_page_observer.dart';
import 'module_param_scheme.dart';
import 'module_route_action.dart';
import 'module_route_builder.dart';
import 'module_route_observer.dart';
import 'module_route_transitions_builder.dart';
import 'module_types.dart';
import 'thrio_module.dart';

final anchor = ModuleAnchor();

class ModuleAnchor
    with
        ThrioModule,
        ModuleJsonSerializer,
        ModuleJsonDeserializer,
        ModulePageObserver,
        ModuleParamScheme,
        ModuleRouteBuilder,
        ModuleRouteObserver,
        ModuleRouteTransitionsBuilder {
  /// Holds PageObserver registered by `NavigatorPageLifecycle`.
  ///
  final pageLifecycleObservers =
      RegistrySetMap<String, NavigatorPageObserver>();

  /// Holds PushHandler registered by `NavigatorRoutePush` .
  ///
  final pushHandlers = RegistrySet<NavigatorRoutePushHandle>();

  /// A collection of route handlers for matching the key's pattern.
  ///
  final routeCustomHandlers =
      RegistryOrderMap<NavigatorUrlTemplate, NavigatorRouteCustomHandler>();

  /// All registered urls.
  ///
  final allUrls = <String>[];

  ModuleContext get rootModuleContext => modules.values.first.moduleContext;

  @override
  Future<void> onModuleInit(ModuleContext moduleContext) =>
      ThrioNavigatorImplement.shared().init(moduleContext);

  Future<dynamic> loading(String url) async {
    final modules = _getModules(url: url);
    for (final module in modules) {
      if (!module.isLoaded) {
        module.isLoaded = true;
        await module.onModuleLoading(module.moduleContext);
      }
    }
  }

  Future<dynamic> unloading(Iterable<NavigatorRoute> allRoutes) async {
    final urls = allRoutes.map<String>((it) => it.settings.url).toSet();
    final notPushedUrls = allUrls.where((it) => !urls.contains(it)).toList();
    final modules = <ThrioModule>{};
    for (final url in notPushedUrls) {
      modules.addAll(_getModules(url: url));
    }
    final notPushedModules = modules
        .where((it) => it is ModulePageBuilder && it.pageBuilder != null)
        .toSet();
    for (final module in notPushedModules) {
      // 页 Module onModuleUnloading
      if (module.isLoaded) {
        module.isLoaded = false;
        await module.onModuleUnloading(module.moduleContext);
        if (module is ModuleParamScheme) {
          module.paramStreamCtrls.clear();
        }
      }
      // 页 Module 的 父 Module onModuleUnloading
      var parentModule = module.parent;
      while (parentModule != null) {
        final leafModules = _getAllLeafModules(parentModule);
        if (notPushedModules.containsAll(leafModules)) {
          if (parentModule.isLoaded) {
            parentModule.isLoaded = false;
            await parentModule.onModuleUnloading(parentModule.moduleContext);
            if (parentModule is ModuleParamScheme) {
              parentModule.paramStreamCtrls.clear();
            }
          }
        }
        parentModule = parentModule.parent;
      }
    }
  }

  T? get<T>({String? url, String? key}) {
    var modules = <ThrioModule>[];
    if (url != null && url.isNotEmpty) {
      final typeString = T.toString();
      modules = _getModules(url: url);
      if (T == ThrioModule || T == dynamic || T == Object) {
        return modules.isEmpty ? null : modules.last as T;
      } else if (typeString == (NavigatorPageBuilder).toString()) {
        if (modules.isEmpty) {
          return null;
        }
        final lastModule = modules.last;
        if (lastModule is ModulePageBuilder) {
          final builder = lastModule.pageBuilder;
          if (builder is NavigatorPageBuilder) {
            return builder as T;
          }
        }
      } else if (typeString == (NavigatorRouteBuilder).toString()) {
        if (modules.isEmpty) {
          return null;
        }
        for (final it in modules.reversed) {
          if (it is ModuleRouteBuilder) {
            if (it.routeBuilder != null) {
              return it.routeBuilder as T;
            }
          }
        }
        return null;
      } else if (typeString == (RouteTransitionsBuilder).toString()) {
        if (modules.isEmpty) {
          return null;
        }
        for (final it in modules.reversed) {
          if (it is ModuleRouteTransitionsBuilder) {
            if (it.routeTransitionsDisabled) {
              return null;
            }
            if (!it.routeTransitionsDisabled &&
                it.routeTransitionsBuilder != null) {
              return it.routeTransitionsBuilder as T;
            }
          }
        }
        return null;
      } else if (typeString == (NavigatorRouteAction).toString()) {
        if (modules.isEmpty || key == null) {
          return null;
        }
        for (final it in modules.reversed) {
          if (it is ModuleRouteAction) {
            final routeAction = it.getRouteAction(key);
            if (routeAction != null) {
              return routeAction as T;
            }
          }
        }
        return null;
      }
    }
    if (modules.isEmpty &&
        (url == null || url.isEmpty || !ThrioModule.contains(url))) {
      modules = _getModules();
    }

    if (key == null || key.isEmpty) {
      return null;
    }
    return _get<T>(modules, key);
  }

  Iterable<T> gets<T>(String url) {
    final modules = _getModules(url: url);
    if (modules.isEmpty) {
      return <T>[];
    }
    final typeString = T.toString();
    if (typeString == (NavigatorPageObserver).toString()) {
      final observers = <NavigatorPageObserver>{};
      for (final module in modules) {
        if (module is ModulePageObserver) {
          observers.addAll(module.pageObservers);
        }
      }
      observers.addAll(pageLifecycleObservers[url]);
      return observers.toList().cast<T>();
    } else if (typeString == (NavigatorRouteObserver).toString()) {
      final observers = <NavigatorRouteObserver>{};
      for (final module in modules) {
        if (module is ModuleRouteObserver) {
          observers.addAll(module.routeObservers);
        }
      }
      return observers.toList().cast<T>();
    }
    return <T>[];
  }

  void set<T>(Comparable<dynamic> key, T value) => setParam(key, value);

  T? remove<T>(Comparable<dynamic> key) => removeParam(key);

  List<ThrioModule> _getModules({String? url}) {
    if (modules.isEmpty) {
      return <ThrioModule>[];
    }
    final firstModule = modules.values.first;
    final allModules = [firstModule];

    if (url == null || url.isEmpty) {
      // 子节点所有的 module
      return allModules..addAll(_getAllModules(firstModule));
    }

    final components =
        url.isEmpty ? <String>[] : url.replaceAll('/', ' ').trim().split(' ');
    final length = components.length;
    ThrioModule? module = firstModule;
    // 确定根节点，根部允许连续的空节点
    if (components.isNotEmpty) {
      final key = components.removeAt(0);
      var m = module.modules[key];
      if (m == null) {
        m = module.modules[''];
        while (m != null) {
          allModules.add(m);
          final m0 = m.modules[key];
          if (m0 == null) {
            m = m.modules[''];
          } else {
            m = m0;
            break;
          }
        }
      }
      if (m == null) {
        return allModules;
      }
      module = m;
      allModules.add(module);
    }
    // 寻找剩余的节点
    while (components.isNotEmpty) {
      final key = components.removeAt(0);
      module = module?.modules[key];
      if (module != null) {
        allModules.add(module);
      }
    }

    // url 不能完全匹配到 module，可能是原生的 url 或者不存在的 url
    if (allModules.where((it) => it.key.isNotEmpty).length != length) {
      return <ThrioModule>[];
    }
    return allModules;
  }

  Iterable<ThrioModule> _getAllModules(ThrioModule module) {
    final subModules = module.modules.values;
    final allModules = [...subModules];
    for (final it in subModules) {
      allModules.addAll(_getAllModules(it));
    }
    return allModules;
  }

  Iterable<ThrioModule> _getAllLeafModules(ThrioModule module) {
    final subModules = module.modules.values;
    final allLeafModules = <ThrioModule>[];
    for (final module in subModules) {
      if (module is ModulePageBuilder) {
        if (module.pageBuilder != null) {
          allLeafModules.add(module);
        }
      } else {
        allLeafModules.addAll(_getAllLeafModules(module));
      }
    }
    return allLeafModules;
  }

  T? _get<T>(List<ThrioModule> modules, String key) {
    final typeString = T.toString();
    if (typeString == (JsonSerializer).toString()) {
      for (final it in modules.reversed) {
        if (it is ModuleJsonSerializer) {
          final jsonSerializer = it.getJsonSerializer(key);
          if (jsonSerializer != null) {
            return jsonSerializer as T;
          }
        }
      }
    } else if (typeString == (JsonDeserializer).toString()) {
      for (final it in modules.reversed) {
        if (it is ModuleJsonDeserializer) {
          final jsonDeserializer = it.getJsonDeserializer(key);
          if (jsonDeserializer != null) {
            return jsonDeserializer as T;
          }
        }
      }
    }
    return null;
  }
}
