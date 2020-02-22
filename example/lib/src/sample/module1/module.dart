import 'package:thrio/thrio.dart';
import 'page1.dart';
import 'page2.dart';

class Module with ThrioModule {
  @override
  void onPageRegister() {
    registerPageBuilder(
      'flutter1',
      (settings) => Page1(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'flutter2',
      (settings) => Page2(index: settings.index, params: settings.params),
    );
  }
}
