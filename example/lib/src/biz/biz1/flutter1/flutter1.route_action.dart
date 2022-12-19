// Copyright (c) 2022 foxsofter.
//

import 'dart:async';

import 'package:example/src/biz/types/people.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

/// get people
///
FutureOr<People?> onGetPeople(
  final ModuleContext moduleContext,
  final String url,
  final String action,
  final Map<String, List<String>> queryParams, {
  final int? intValue,
}) =>
    Future.value(People(name: 'name', age: intValue ?? 1, sex: 'sex'));

/// get string
///
FutureOr<String?> onGetString(
  final ModuleContext moduleContext,
  final String url,
  final String action,
  final Map<String, List<String>> queryParams, {
  final bool boolValue = false,
}) =>
    'goodman';
