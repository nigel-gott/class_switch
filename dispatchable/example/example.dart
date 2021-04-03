import 'package:dispatchable/dispatchable.dart';

part 'example.g.dart';

@Dispatchable()
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

void main() {
  assert(_$FruitDispatcher.acceptFunc((apple) {
        return 1;
      }, (orange) {
        return 2;
      })(Apple()) ==
      1);
  assert(MyFruitHandler().accept(Orange()) == 2);
  assert(MyFruitHandlerWithADefault().accept(Orange()) == 'orange is special');
}

class MyFruitHandler extends _$FruitDispatcher<int> {
  @override
  int apple(Apple apple) {
    return 1;
  }

  @override
  int orange(Orange orange) {
    return 2;
  }
}

class MyFruitHandlerWithADefault extends _$FruitDispatcherWithDefault<String> {
  @override
  String defaultValue() {
    return 'default';
  }

  @override
  String orange(Orange orange) {
    return 'orange is special';
  }
}
