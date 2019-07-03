import 'package:type_handler/type_handler.dart';

part 'base.g.dart';

main() {
  print(fruitHandler((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

@Subtype()
class Fruit {}

class Apple extends Fruit {}

@Subtype()
class Orange extends Fruit {}

class A extends Orange {}

@Subtype()
class X {}

class Y extends X {}
