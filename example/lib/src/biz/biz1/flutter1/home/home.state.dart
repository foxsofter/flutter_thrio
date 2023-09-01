// Copyright (c) 2023 foxsofter.
//
// ignore_for_file: avoid_as

part of 'home.page.dart';

extension Home on State<HomePage> {
  /// hello, this is a list.
  ///
  List<String> get strList => widget.getListParam<String>('strList');

  /// hello, this is a map.
  ///
  Map<String, dynamic> get goodMap =>
      widget.getMapParam<String, dynamic>('goodMap');
}
