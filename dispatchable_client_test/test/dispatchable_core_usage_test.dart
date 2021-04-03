import 'package:dispatchable/dispatchable.dart';
import 'package:test/test.dart';

part 'dispatchable_core_usage_test.g.dart';

@Dispatchable()
abstract class Fruit {}

class Apple extends Fruit {}

class Pear extends Fruit {}

class Orange extends Fruit {}

class FruitNamer extends _$FruitDispatcher<String> {
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

class IsAnAppleChecker extends _$FruitDispatcherWithDefault<bool> {
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
  group('Tests showing core dispatchable library usage.', () {
    group('Annotating a class with @Dispatchable() will generate:', () {
      test(
          'A class with abstract methods for each sub-class and a method '
          'dispatching to the corresponding abstract subtype method.', () {
        var fruitNamer = FruitNamer();
        expect(fruitNamer.accept(Apple()), 'Apple');
        expect(fruitNamer.accept(Pear()), 'Pear');
        expect(fruitNamer.accept(Orange()), 'Orange');
      });
      test(
          'A class with an abstract default method and non abstract sub-class '
          'methods which return the default if not overridden plus the '
          'dispatch method.', () {
        var appleChecker = IsAnAppleChecker();
        expect(appleChecker.accept(Apple()), true);
        expect(appleChecker.accept(Pear()), false);
        expect(appleChecker.accept(Orange()), false);
      });
      test(
          'A static method which takes a function per sub-class and returns a '
          'sub-class dispatch method using the provided functions.', () {
        var fruitDispatchFunction =
            _$FruitDispatcher.acceptFunc<int>((Apple apple) {
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

int Function(Fruit) aDispatcherFunction() {
  return _$FruitDispatcher.acceptFunc<int>((Apple apple) {
    return 1;
  }, (Pear pear) {
    return 2;
  }, (Orange orange) {
    return 3;
  });
}
