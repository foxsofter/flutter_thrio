// Copyright (c) 2023 foxsofter.
//
// ignore_for_file: avoid_as

part of 'flutter4.page.dart';

extension Flutter4 on _Flutter4PageState {
  /// hello, this is a people
  ///
  People get people => widget.getParam<People>('people');
}