// Copyright (c) 2019/2/28, 13:31:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/widgets.dart';

typedef NavigatorPageBuilder = Widget Function(RouteSettings settings);

typedef NavigatorPageNotifyCallback = void Function(
  Map<String, dynamic> params,
);
