import '../thrio_types.dart';

extension RouterContainerLifecycleX on RouterContainerLifecycle {
  String castToString() => toString().split('.').last;

  static RouterContainerLifecycle castFromString(String value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    const lifecycles = <String, RouterContainerLifecycle>{
      'inited': RouterContainerLifecycle.inited,
      'willAppear': RouterContainerLifecycle.willAppear,
      'appeared': RouterContainerLifecycle.appeared,
      'willDisappear': RouterContainerLifecycle.willDisappear,
      'disappeared': RouterContainerLifecycle.disappeared,
      'destroyed': RouterContainerLifecycle.destroyed,
      'background': RouterContainerLifecycle.background,
      'foreground': RouterContainerLifecycle.foreground,
    };
    return lifecycles[value];
  }
}