// Copyright (c) 2023 foxsofter.
//

import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

part 'flutter9.context.dart';
part 'flutter9.state.dart';

class Flutter9Page extends NavigatorStatefulPage {
  const Flutter9Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter9PageState createState() => _Flutter9PageState();
}

class _Flutter9PageState extends State<Flutter9Page> {
  @override
  Widget build(final BuildContext context) => Container();
}
