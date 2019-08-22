import 'package:class_switch_annotation/class_switch_annotation.dart';
import 'package:test/test.dart';

part 'class_switch_library_core_usage_test.g.dart';

@class_switch
abstract class Fruit {}

class Apple extends Fruit {}

class Pear extends Fruit {}

class Orange extends Fruit {}

class FruitNamer extends FruitSwitcher<String> {
  @override
  String apple(Apple apple) {
    return "Apple";
  }

  @override
  String pear(Pear pear) {
    return "Pear";
  }

  @override
  String orange(Orange orange) {
    return "Orange";
  }
}

class IsAnAppleChecker extends FruitSwitcherWithDefault<bool> {
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
    group('Annotating a class with @subtype will generate:', () {
      test(
          'A class with abstract methods for each sub-class and a method dispatching to the corrosponding abstract subtype method.',
          () {
        FruitNamer fruitNamer = FruitNamer();
        expect(fruitNamer.acceptFruit(Apple()), "Apple");
        expect(fruitNamer.acceptFruit(Pear()), "Pear");
        expect(fruitNamer.acceptFruit(Orange()), "Orange");
      });
      test(
          'A class with an abstract default method and non abstract sub-class methods which return the default if not overriden plus the dispatch method.',
          () {
        IsAnAppleChecker appleChecker = IsAnAppleChecker();
        expect(appleChecker.acceptFruit(Apple()), true);
        expect(appleChecker.acceptFruit(Pear()), false);
        expect(appleChecker.acceptFruit(Orange()), false);
      });
      test(
          'A static method which takes a function per sub-class and returns a sub-class dispatch method using the provided functions.',
          () {
        int Function(Fruit) fruitDispatchFunction =
            FruitSwitcher.fruitSwitcher<int>((Apple apple) {
          return 1;
        }, (Pear pear) {
          return 2;
        }, (Orange orange) {
          return 3;
        });

        expect(fruitDispatchFunction(Apple()), 1);
        expect(fruitDispatchFunction(Pear()), 2);
        expect(fruitDispatchFunction(Orange()), 3);
      });
    });
  });
}
