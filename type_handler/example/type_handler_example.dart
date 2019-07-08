import 'package:type_handler/type_handler.dart';

main() {
  print(fruitHandler((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));

  print(MyHandler().handle(Orange()));
  print(MyHandler().handle(Apple()));
}

Function(Fruit) fruitHandler<T>(
    T Function(Apple) apple, T Function(Orange) orange) {
  return (fruit) {
    if (fruit is Apple) {
      return apple(fruit);
    } else if (fruit is Orange) {
      return orange(fruit);
    } else {
      throw UnimplementedError(
          "Unknown class given to handler: $fruit. You must annotate every subtype. ");
    }
  };
}

class MyHandler extends FruitHandlerWithDefault<int> {
  @override
  int defaultResult() {
    return 2;
  }

  @override
  int apple(Apple apple) {
    return 3;
  }
}

abstract class FruitHandler<T> {
  T handle(Fruit fruit) {
    return fruitHandler(apple, orange)(fruit);
  }

  T apple(Apple apple);

  T orange(Orange orange);
}

abstract class FruitHandlerWithDefault<T> {
  T handle(Fruit fruit) {
    return fruitHandler(apple, orange)(fruit);
  }

  T apple(Apple apple) {
    return defaultResult();
  }

  T orange(Orange orange) {
    return defaultResult();
  }

  T defaultResult();
}

class Fruit {}

@Subtype()
class Apple extends Fruit {}

@Subtype()
class Orange extends Fruit {}
