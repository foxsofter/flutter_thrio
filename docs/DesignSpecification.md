# thrio 的设计规范

1. 以 Dart 端需求为主，iOS 端和 Android 端提供类似功能
2. 三端保持一致的外露 API，命名尽量与 Dart 保持一致
3. 设计功能时，要支持多引擎模式
4. 短期内不提供 present 和 dismiss，因为会导致页面栈断层
