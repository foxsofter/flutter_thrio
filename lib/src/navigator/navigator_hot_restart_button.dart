import 'package:flutter/material.dart';

import 'thrio_navigator_implement.dart';

class NavigatorHotRestartButton extends StatefulWidget {
  const NavigatorHotRestartButton({
    super.key,
    this.style,
  });

  final ButtonStyle? style;

  @override
  State<NavigatorHotRestartButton> createState() => _NavigatorHotRestartButtonState();
}

class _NavigatorHotRestartButtonState extends State<NavigatorHotRestartButton> {
  @override
  Widget build(final BuildContext context) => ElevatedButton(
        style: widget.style,
        onPressed: () => ThrioNavigatorImplement.shared().hotRestart(),
        child: const Center(child: Text('hot restart')),
      );
}
