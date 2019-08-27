import 'package:dispatchable_annotation/dispatchable_annotation.dart';

part 'base.g.dart';

@dispatchable
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

main() {
  assert(FruitDispatcher.fruitDispatcher((apple) {
        return 1;
      }, (orange) {
        return 2;
      })(Apple()) ==
      1);
  assert(MyFruitHandler().acceptFruit(Orange()) == 2);
  assert(MyFruitHandlerWithADefault().acceptFruit(Orange()) ==
      "orange is special");
}

class MyFruitHandler extends FruitDispatcher<int> {
  @override
  int apple(Apple apple) {
    return 1;
  }

  @override
  int orange(Orange orange) {
    return 2;
  }
}

class MyFruitHandlerWithADefault extends FruitDispatcherWithDefault<String> {
  @override
  String defaultValue() {
    return "default";
  }

  @override
  String orange(Orange orange) {
    return "orange is special";
  }
}
