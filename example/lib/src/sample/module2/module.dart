import 'package:thrio/thrio.dart';
import 'page3.dart';
import 'page4.dart';

class Module with ThrioModule {
  @override
  void onPageRegister() {
    registerPageBuilder(
      'biz1/flutter3',
      (settings) => Page3(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'biz2/flutter4',
      (settings) => Page4(index: settings.index, params: settings.params),
    );
  }
}
