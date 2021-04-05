import 'package:class_switch/class_switch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
class _$BaseClassSwitchWrapper<T> {
  final BaseClass baseClassAttr;
  _$BaseClassSwitchWrapper(this.baseClassAttr);
  T call(T Function(SubClassA subClassA) subClassA,
      T Function(SubClassB subClassB) subClassB) {
    var baseClassParam = baseClassAttr;
    if (baseClassParam is SubClassA) {
      return subClassA(baseClassParam);
    } else if (baseClassParam is SubClassB) {
      return subClassB(baseClassParam);
    } else {
      throw ArgumentError(
          'Unknown class given to \$switch: $baseClassAttr. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for any of: BaseClass without running pub run build_runner build?. ');
    }
  }

  T cases(T Function(SubClassA subClassA) subClassA,
      T Function(SubClassB subClassB) subClassB) {
    return call(subClassA, subClassB);
  }
}

_$BaseClassSwitchWrapper<T> $switchBaseClass<T>(BaseClass baseClassParam) {
  return _$BaseClassSwitchWrapper<T>(baseClassParam);
}

extension _$BaseClassSwitchExtension on BaseClass {
  T $switch<T>(T Function(SubClassA subClassA) subClassA,
      T Function(SubClassB subClassB) subClassB) {
    return _$BaseClassSwitchWrapper<T>(this)(subClassA, subClassB);
  }
}

abstract class _$BaseClassSwitcherWithDefault<T> {
  T $switch(BaseClass baseClass) {
    return _$BaseClassSwitchWrapper<T>(baseClass)(subClassA, subClassB);
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
    return _$BaseClassSwitchWrapper<T>(baseClass)(subClassA, subClassB);
  }

  T subClassA(SubClassA subClassA);
  T subClassB(SubClassB subClassB);
}
''')
@ClassSwitch()
abstract class BaseClass {}

class SubClassA extends BaseClass {}

class SubClassB extends BaseClass {}
