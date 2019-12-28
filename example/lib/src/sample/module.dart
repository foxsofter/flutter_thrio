import 'package:thrio/thrio.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';

class Module with ThrioModule {
  @override
  void onPageRegister() {
    ThrioRouter().registryPageBuilder(
      'page1',
      (url, {index, params}) => Page1(index: index, params: params),
    );
    ThrioRouter().registryPageBuilder(
      'page2',
      (url, {index, params}) => Page2(),
    );
    ThrioRouter().registryPageBuilder(
      'page3',
      (url, {index, params}) => Page3(),
    );
  }
}
