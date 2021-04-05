import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

part 'class_switch_multi_file_test.g.dart';
part 'sub_types_in_separate_file.dart';

@ClassSwitch()
abstract class Fruit {}

class Apple extends Fruit {
  String get appleOnly => 'apple';
}

void main() {
  group(
      'Tests showing class_switch usage when some sub classes are in a different file.',
      () {
    group('Annotating a class with @ClassSwitch() will generate:', () {
      test('Extension methods allowing switching over an instance directly ',
          () {
        Fruit orange = Orange();
        var r = orange.$switch(
            (apple) => apple.appleOnly, //
            (pear) => 'pear',
            (orange) => 'orange');
        assert(r == 'orange');

        Fruit f = Pear();
        r = f.$switch(
            (apple) => apple.appleOnly, //
            (pear) => 'pear',
            (orange) => 'orange');
        assert(r == 'pear');
      });
    });
  });
}
