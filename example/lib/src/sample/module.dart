import 'package:thrio/thrio.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';
import 'page4.dart';

class Module with ThrioModule {
  @override
  void onPageRegister() {
    registerPageBuilder(
      'flutter1',
      (settings) => Page1(
        index: settings.index,
        params: settings.params,
      ),
    );
    registerPageBuilder(
      'flutter2',
      (settings) => Page2(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'flutter3',
      (settings) => Page3(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'flutter4',
      (settings) => Page4(index: settings.index, params: settings.params),
    );
  }
}
