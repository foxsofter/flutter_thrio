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

import 'package:flutter/foundation.dart';

import '../registry/registry_map.dart';
import 'module_types.dart';
import 'thrio_module.dart';

mixin ModuleJsonSerializer on ThrioModule {
  /// Json serializer registered in the current Module
  ///
  final _jsonSerializers = RegistryMap<Type, JsonSerializer>();

  /// Get json serializer by type string.
  ///
  @protected
  JsonSerializer? getJsonSerializer(String typeString) {
    final type = _jsonSerializers.keys.lastWhere(
        (it) =>
            it.toString() == typeString || typeString.endsWith(it.toString()),
        orElse: () => Null);
    return _jsonSerializers[type];
  }

  /// A function for register a json serializer.
  ///
  @protected
  void onJsonSerializerRegister(ModuleContext moduleContext) {}

  /// Register a json serializer for the module.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  @protected
  VoidCallback registerJsonSerializer<T>(JsonSerializer serializer) =>
      _jsonSerializers.registry(T, serializer);
}
