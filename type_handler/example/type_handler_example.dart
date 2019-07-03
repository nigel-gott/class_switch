import 'package:type_handler/type_handler.dart';

main() {
  print(fruitHandler((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
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

class Fruit {}

@Subtype()
class Apple extends Fruit {}

@Subtype()
class Orange extends Fruit {}
