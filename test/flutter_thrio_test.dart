import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

void main() {
  test(' async task queue', () async {
    final queue = AsyncTaskQueue();
    var idx = 0;
    Future<int> f() {
      idx += 1;
      // print('begin with $idx');
      return Future.delayed(const Duration(microseconds: 10), () {
        // print('executing with $idx');
        if (idx == 3) {
          throw ArgumentError.value(idx);
        }
        if (idx == 4) {
          // var r = queue.add(f, debugLabel: '6');
          // r.then<void>((value) => queue.add(f, debugLabel: '7'));
        }
        return idx;
      });
    }

    // var r = queue.add(f, debugLabel: '1');
    // var s = r.then<void>((value) => print('end with $value'));
    // r = queue.add(f, debugLabel: '2');
    // s = r.then<void>((value) => print('end with $value'));
    // r = queue.add(f, debugLabel: '3');
    // s = r.then<void>((value) => print('end with $value'));
    // r = queue.add(f, debugLabel: '4');
    // s = r.then<void>((value) => print('end with $value'));
    // r = queue.add(f, debugLabel: '5');
    // s = r.then<void>((value) => print('end with $value'));
    // await r;
  });

  test('getPlatformVersion', () async {});
}
