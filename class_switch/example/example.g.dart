// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// ClassSwitchGenerator
// **************************************************************************

class $SwitchFruit<T> {
  final Fruit fruitAttr;
  $SwitchFruit(this.fruitAttr);
  T call(T Function(Apple) apple, T Function(Orange) orange) {
    var fruitParam = fruitAttr;
    if (fruitParam is Apple) {
      return apple(fruitParam);
    } else if (fruitParam is Orange) {
      return orange(fruitParam);
    } else {
      throw ArgumentError(
          'Unknown class given to \$switch: $fruitAttr. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for any of: Fruit without running pub run build_runner build?. ');
    }
  }

  T cases(T Function(Apple) apple, T Function(Orange) orange) {
    return call(apple, orange);
  }
}

$SwitchFruit<T> $switchFruit<T>(Fruit fruitParam) {
  return $SwitchFruit<T>(fruitParam);
}

extension _$FruitSwitchExtension on Fruit {
  T $switch<T>(T Function(Apple) apple, T Function(Orange) orange) {
    return $SwitchFruit<T>(this)(apple, orange);
  }
}

abstract class _$FruitSwitcherWithDefault<T> {
  T $switch(Fruit fruit) {
    return $SwitchFruit<T>(fruit)(apple, orange);
  }

  T defaultValue();
  T apple(Apple apple) {
    return defaultValue();
  }

  T orange(Orange orange) {
    return defaultValue();
  }
}

abstract class _$FruitSwitcher<T> {
  T $switch(Fruit fruit) {
    return $SwitchFruit<T>(fruit)(apple, orange);
  }

  T apple(Apple apple);
  T orange(Orange orange);
}
