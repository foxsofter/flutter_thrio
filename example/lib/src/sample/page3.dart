import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

class Page3 extends StatefulWidget {
  const Page3({
    Key key,
    this.index,
    this.params,
  }) : super(key: key);

  final int index;

  final Map<String, dynamic> params;

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            textTheme: TextTheme(title: TextStyle(color: Colors.black)),
            title: const Text('thrio_example'),
            leading: IconButton(
              color: Colors.black,
              tooltip: 'back',
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: ThrioNavigator.pop,
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'flutter3: index is ${widget.index}',
                        style: TextStyle(fontSize: 28, color: Colors.blue),
                      ),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: 'flutter4',
                        params: {
                          '1': {'2': '3'}
                        },
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'push flutter4',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.remove(url: 'flutter2'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'remove flutter2',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: ThrioNavigator.pop,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'pop',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.popTo(url: 'flutter1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: Text(
                            'popTo flutter1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: 'native1',
                        params: {
                          '1': {'2': '3'}
                        },
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: Text(
                            'push native1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.remove(url: 'native1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: Text(
                            'pop native1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                  ]),
            ),
          )));
}
