import 'package:class_switch/class_switch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
extensions _$FruitSwitch on BaseClass {

    T $switch<T>(T Function(SubClassA) subClassA, T Function(SubClassB) subClassB) {
      var baseClassParam = this;
      if (baseClassParam is SubClassA) {
        return subClassA(baseClassParam);
      } else if (baseClassParam is SubClassB) {
        return subClassB(baseClassParam);
      } else {
        throw ArgumentError(
            "Unknown class passed to baseClass.$switch: $baseClassParam. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for: BaseClass without running pub run build_runner build?. ");
      }
  }

}

abstract class _$BaseClassSwitcherWithDefault<T> {
  T $switch(BaseClass baseClass) {
    return baseClass.$switch(subClassA, subClassB);
  }

  T defaultValue();
  T subClassA(SubClassA subClassA) {
    return defaultValue();
  }

  T subClassB(SubClassB subClassB) {
    return defaultValue();
  }
}

abstract class _$BaseClassSwitcher<T> {
  T $switch(BaseClass baseClass) {
    return baseClass.$switch(subClassA, subClassB);
  }

  T subClassA(SubClassA subClassA);
  T subClassB(SubClassB subClassB);
}
''')
@ClassSwitch()
abstract class BaseClass {}

class SubClassA extends BaseClass {}

class SubClassB extends BaseClass {}
