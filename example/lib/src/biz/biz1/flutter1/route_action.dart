import 'dart:async';

import 'package:example/src/biz/types/people.dart';

FutureOr<People?> getPeople(
  final String url,
  final String action,
  final Map<String, List<String>> queryParams, {
  required final int intValue,
}) =>
    Future.value(People(name: 'name', age: intValue, sex: 'sex'));
