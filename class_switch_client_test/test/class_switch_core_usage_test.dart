import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

part 'class_switch_core_usage_test.g.dart';

@ClassSwitch()
abstract class Fruit {}

class Apple extends Fruit {}

class Pear extends Fruit {}

class Orange extends Fruit {}

class FruitNamer extends _$FruitSwitcher<String> {
  @override
  String apple(Apple apple) {
    return 'Apple';
  }

  @override
  String pear(Pear pear) {
    return 'Pear';
  }

  @override
  String orange(Orange orange) {
    return 'Orange';
  }
}

class IsAnAppleChecker extends _$FruitSwitcherWithDefault<bool> {
  @override
  bool defaultValue() {
    return false;
  }

  @override
  bool apple(Apple apple) {
    return true;
  }
}

void main() {
  group('Tests showing core class_switch library usage.', () {
    group('Annotating a class with @ClassSwitch() will generate:', () {
      test(
          'A class with abstract methods for each sub-class and a method '
          'switching to the corresponding abstract subtype method.', () {
        var fruitNamer = FruitNamer();
        expect(fruitNamer.$switch(Apple()), 'Apple');
        expect(fruitNamer.$switch(Pear()), 'Pear');
        expect(fruitNamer.$switch(Orange()), 'Orange');
      });
      test(
          'A class with an abstract default method and non abstract sub-class '
          'methods which return the default if not overridden plus the '
          'switch method.', () {
        var appleChecker = IsAnAppleChecker();
        expect(appleChecker.$switch(Apple()), true);
        expect(appleChecker.$switch(Pear()), false);
        expect(appleChecker.$switch(Orange()), false);
      });
      test(
          'A static method which takes an instance of the annotated classes '
          'returning a function which takes a function per sub-class, which'
          'then switches over the instance calling the correct provided '
          'function', () {
        var fruitToNumber = (f) => $switchFruit<int>(f)(
            (Apple apple) => 1, //
            (Pear pear) => 2,
            (Orange orange) => 3);

        expect(fruitToNumber(Apple()), 1);
        expect(fruitToNumber(Pear()), 2);
        expect(fruitToNumber(Orange()), 3);
      });
    });
  });
}
