// Copyright (c) 2024 foxsofter.
//
// Do not edit this file.
//

part of 'home.page.dart';

extension HomeContext on ModuleContext {
  String get stringKeyBiz1 =>
      get<String>('stringKeyBiz1') ??
      (throw ArgumentError('stringKeyBiz1 not exists'));

  String? get stringKeyBiz1OrNull => get<String>('stringKeyBiz1');

  String get stringKeyBiz1OrDefault => get<String>('stringKeyBiz1') ?? 'weewr';

  bool setStringKeyBiz1(final String value) =>
      set<String>('stringKeyBiz1', value);

  String? removeStringKeyBiz1() => remove<String>('stringKeyBiz1');

  Stream<String> get onStringKeyBiz1 =>
      on<String>('stringKeyBiz1') ??
      (throw ArgumentError('stringKeyBiz1 stream not exists'));

  Stream<String?> get onStringKeyBiz1WithNull =>
      onWithNull<String>('stringKeyBiz1') ??
      (throw ArgumentError('stringKeyBiz1 stream not exists'));

  Stream<String> get onStringKeyBiz1WithInitial =>
      on<String>('stringKeyBiz1', initialValue: 'weewr') ??
      (throw ArgumentError('stringKeyBiz1 stream not exists'));

  int get intKeyRootModule =>
      get<int>('intKeyRootModule') ??
      (throw ArgumentError('intKeyRootModule not exists'));

  bool setIntKeyRootModule(final int value) =>
      set<int>('intKeyRootModule', value);

  Stream<int> get onIntKeyRootModule =>
      on<int>('intKeyRootModule') ??
      (throw ArgumentError('intKeyRootModule stream not exists'));

  Stream<int?> get onIntKeyRootModuleWithNull =>
      onWithNull<int>('intKeyRootModule') ??
      (throw ArgumentError('intKeyRootModule stream not exists'));

  Stream<int> onIntKeyRootModuleWithInitial(
          {required final int initialValue}) =>
      on<int>('intKeyRootModule', initialValue: initialValue) ??
      (throw ArgumentError('intKeyRootModule stream not exists'));

  People get people =>
      get<People>('people') ?? (throw ArgumentError('people not exists'));

  People? get peopleOrNull => get<People>('people');

  People getPeopleOrDefault({required final People defaultValue}) =>
      get<People>('people') ?? defaultValue;

  bool setPeople(final People value) => set<People>('people', value);

  People? removePeople() => remove<People>('people');

  Stream<People> get onPeople =>
      on<People>('people') ?? (throw ArgumentError('people stream not exists'));

  Stream<People?> get onPeopleWithNull =>
      onWithNull<People>('people') ??
      (throw ArgumentError('people stream not exists'));

  Stream<People> onPeopleWithInitial({required final People initialValue}) =>
      on<People>('people', initialValue: initialValue) ??
      (throw ArgumentError('people stream not exists'));
}
