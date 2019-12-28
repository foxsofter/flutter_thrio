import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({
    Key key,
    this.index,
    this.params,
  }) : super(key: key);

  final int index;

  final Map<String, dynamic> params;

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) => Container(
        child: Center(
          child: Text('Sample Page1: index is ${widget.index}'),
        ),
      );
}
