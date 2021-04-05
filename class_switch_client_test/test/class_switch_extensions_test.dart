import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

part 'class_switch_extensions_test.g.dart';

@ClassSwitch()
abstract class Fruit {}

class Apple extends Fruit {
  String get appleOnly => 'apple';
}

class Pear extends Fruit {}

class Orange extends Fruit {}

void main() {
  group('Tests showing class_switch extension method usage.', () {
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
