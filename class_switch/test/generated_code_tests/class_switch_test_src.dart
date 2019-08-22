import 'package:class_switch_annotation/class_switch_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
abstract class BaseClassSwitcherWithDefault<T> {
  T acceptBaseClass(BaseClass baseClassInstance) {
    return BaseClassSwitcher.baseClassSwitcher(subClassA, subClassB)(
        baseClassInstance);
  }

  T defaultValue();

  T subClassA(SubClassA subClassA) {
    return defaultValue();
  }

  T subClassB(SubClassB subClassB) {
    return defaultValue();
  }
}

abstract class BaseClassSwitcher<T> {
  static T Function(BaseClass) baseClassSwitcher<T>(
      T Function(SubClassA) subClassA, T Function(SubClassB) subClassB) {
    return (baseClassInstance) {
      if (baseClassInstance is SubClassA) {
        return subClassA(baseClassInstance);
      } else if (baseClassInstance is SubClassB) {
        return subClassB(baseClassInstance);
      } else {
        throw UnimplementedError(
            "Unknown class given to switcher: $baseClassInstance. subClass code generation has done something incorrectly. ");
      }
    };
  }

  T acceptBaseClass(BaseClass baseClassInstance) {
    return baseClassSwitcher(subClassA, subClassB)(baseClassInstance);
  }

  T subClassA(SubClassA subClassA);
  T subClassB(SubClassB subClassB);
}
''')
@class_switch
abstract class BaseClass {}

class SubClassA extends BaseClass {}

class SubClassB extends BaseClass {}
