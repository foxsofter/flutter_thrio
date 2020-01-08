import 'package:thrio/thrio.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';

class Module with ThrioModule {
  @override
  void onPageRegister() {
    ThrioApp().registryPageBuilder(
      'flutter1',
      (url, {index, params}) => Page1(index: index, params: params),
    );
    ThrioApp().registryPageBuilder(
      'flutter2',
      (url, {index, params}) => Page2(index: index, params: params),
    );
    ThrioApp().registryPageBuilder(
      'flutter3',
      (url, {index, params}) => Page3(index: index, params: params),
    );
    ThrioApp()
        .onPageLifecycleStream(PageLifecycle.appeared, 'flutter1')
        .listen((index) {
      ThrioLogger().v(index);
      return;
    });
  }
}
