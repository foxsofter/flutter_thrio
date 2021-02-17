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
import '../navigator/navigator_page_route.dart';
import '../navigator/navigator_route_observer.dart';
import '../navigator/navigator_route_settings.dart';
import '../navigator/navigator_types.dart';
import '../navigator/thrio_navigator_implement.dart';
import '../registry/registry_set_map.dart';
import 'module_json_deserializer.dart';
import 'module_json_serializer.dart';
import 'module_page_builder.dart';
import 'module_page_observer.dart';
import 'module_param_scheme.dart';
import 'module_protobuf_deserializer.dart';
import 'module_protobuf_serializer.dart';
import 'module_route_observer.dart';
import 'module_route_transitions_builder.dart';
import 'module_types.dart';
import 'thrio_module.dart';

final anchor = ModuleAnchor();

class ModuleAnchor
    with
        ThrioModule,
        ModulePageObserver,
        ModuleJsonDeserializer,
        ModuleProtobufSerializer,
        ModuleProtobufDeserializer,
        ModuleParamScheme,
        ModuleJsonSerializer,
        ModuleRouteObserver,
        ModuleRouteTransitionsBuilder {
  /// Holds PageObserver registered by `NavigatorPageLifecycle`.
  ///
  final pageLifecycleObservers =
      RegistrySetMap<String, NavigatorPageObserver>();

  /// All registered urls.
  ///
  final allUrls = <String>[];

  @override
  void onModuleInit(ModuleContext moduleContext) {
    ThrioNavigatorImplement.shared().init(moduleContext);
  }

  Future loading(String url) async {
    final modules = _getModules(url: url);
    if (modules == null) {
      return;
    }

    for (final module in modules) {
      if (!module.isLoaded) {
        module.isLoaded = true;
        await module.onModuleLoading(module.moduleContext);
      }
    }
  }

  Future unloading(Iterable<NavigatorPageRoute> allRoutes) async {
    final urls = allRoutes.map<String>((it) => it.settings.url).toSet();
    final notPushedUrls = allUrls.where((it) => !urls.contains(it)).toList();
    // 需要过滤掉不带 home 的 url
    for (var i = notPushedUrls.length - 1; i >= 0; i--) {
      final url = notPushedUrls[i];
      if (url.endsWith('/home')) {
        final shortUrl = url.replaceRange(url.length - 5, url.length, '');
        if (!notPushedUrls.remove(shortUrl)) {
          if (allUrls.contains(shortUrl)) {
            notPushedUrls.remove(url);
          }
        }
      }
    }
    final modules = <ThrioModule>{};
    for (final url in notPushedUrls) {
      modules.addAll(_getModules(url: url));
    }
    final notPushedModules = modules
        .where(
          (it) => it is ModulePageBuilder && it.pageBuilder != null,
        )
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
      do {
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
      } while (parentModule != null);
    }
  }

  T get<T>({String url, String key}) {
    var modules = _getModules(url: url);
    if (url?.isNotEmpty ?? false) {
      if (T == ThrioModule || T == dynamic || T == Object) {
        return modules == null ? null : modules.last as T;
      } else if (T == NavigatorPageBuilder) {
        if (modules == null) {
          return null;
        }
        final lastModule = modules.last;
        if (lastModule is ModulePageBuilder) {
          return lastModule.pageBuilder as T;
        }
      } else if (T == RouteTransitionsBuilder) {
        if (modules == null) {
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
      } else {
        modules ??= _getModules();
      }
    }
    return _get<T>(modules, key);
  }

  Iterable<T> gets<T>(String url) {
    final modules = _getModules(url: url);
    if (modules == null) {
      return <T>[];
    }
    switch (T) {
      case NavigatorPageObserver:
        final observers = <NavigatorPageObserver>{};
        for (final module in modules) {
          if (module is ModulePageObserver) {
            observers.addAll(module.pageObservers);
          }
        }
        observers.addAll(pageLifecycleObservers[url]);
        return observers.toList().cast<T>();
      case NavigatorRouteObserver:
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

  void set<T>(Comparable key, T value) => setParam(key, value);

  T remove<T>(Comparable key) => removeParam(key);

  List<ThrioModule> _getModules({String url}) {
    var module = modules.values.first;
    final allModules = [module];

    if (url?.isEmpty ?? true) {
      return allModules..addAll(_getAllModules(module));
    }

    final components = url?.isEmpty ?? true
        ? <String>[]
        : url.replaceAll('/', ' ').trim().split(' ');
    final length = components.length;
    do {
      final key = components.removeAt(0);
      if (key?.isEmpty ?? true) {
        break;
      }
      module = module.modules[key];
      if (module != null) {
        allModules.add(module);
      }
    } while (components.isNotEmpty);

    // url 不能完全匹配到 module，可能是原生的 url 或者不存在的 url
    if (allModules.length != length + 1) {
      return null;
    }

    if (!url.endsWith(kNavigatorPageDefaultUrl) &&
        allModules.last.modules.containsKey(kNavigatorPageDefaultUrl)) {
      allModules.add(allModules.last.modules[kNavigatorPageDefaultUrl]);
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

  T _get<T>(List<ThrioModule> modules, String key) {
    switch (T) {
      case JsonSerializer:
        for (final it in modules.reversed) {
          if (it is ModuleJsonSerializer) {
            final jsonSerializer = it.getJsonSerializer(key);
            if (jsonSerializer != null) {
              return jsonSerializer as T;
            }
          }
        }
        break;
      case JsonDeserializer:
        for (final it in modules.reversed) {
          if (it is ModuleJsonDeserializer) {
            final jsonDeserializer = it.getJsonDeserializer(key);
            if (jsonDeserializer != null) {
              return jsonDeserializer as T;
            }
          }
        }
        break;
      case ProtobufSerializer:
        for (final it in modules.reversed) {
          if (it is ModuleProtobufSerializer) {
            final protobufSerializer = it.getProtobufSerializer(key);
            if (protobufSerializer != null) {
              return protobufSerializer as T;
            }
          }
        }
        break;
      case ProtobufDeserializer:
        for (final it in modules.reversed) {
          if (it is ModuleProtobufDeserializer) {
            final protobufDeserializer = it.getProtobufDeserializer(key);
            if (protobufDeserializer != null) {
              return protobufDeserializer as T;
            }
          }
        }
        break;
    }
    return null;
  }
}
