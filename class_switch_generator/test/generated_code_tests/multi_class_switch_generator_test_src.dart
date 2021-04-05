import 'package:class_switch/class_switch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
class _$BaseOtherBaseSwitchWrapper<T> {
  final Base baseAttr;
  final OtherBase otherBaseAttr;
  _$BaseOtherBaseSwitchWrapper(this.baseAttr, this.otherBaseAttr);
  T call(
      T Function(A a, OtherA otherA) aOtherA,
      T Function(A a, OtherB otherB) aOtherB,
      T Function(B b, OtherA otherA) bOtherA,
      T Function(B b, OtherB otherB) bOtherB) {
    var baseParam = baseAttr;
    var otherBaseParam = otherBaseAttr;
    if (baseParam is A && otherBaseParam is OtherA) {
      return aOtherA(baseParam, otherBaseParam);
    } else if (baseParam is A && otherBaseParam is OtherB) {
      return aOtherB(baseParam, otherBaseParam);
    } else if (baseParam is B && otherBaseParam is OtherA) {
      return bOtherA(baseParam, otherBaseParam);
    } else if (baseParam is B && otherBaseParam is OtherB) {
      return bOtherB(baseParam, otherBaseParam);
    } else {
      throw ArgumentError(
          'Unknown class given to \$switch: $baseAttr, $otherBaseAttr. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for any of: Base, OtherBase without running pub run build_runner build?. ');
    }
  }

  T cases(
      T Function(A a, OtherA otherA) aOtherA,
      T Function(A a, OtherB otherB) aOtherB,
      T Function(B b, OtherA otherA) bOtherA,
      T Function(B b, OtherB otherB) bOtherB) {
    return call(aOtherA, aOtherB, bOtherA, bOtherB);
  }
}

_$BaseOtherBaseSwitchWrapper<T> $switchBaseOtherBase<T>(
    Base baseParam, OtherBase otherBaseParam) {
  return _$BaseOtherBaseSwitchWrapper<T>(baseParam, otherBaseParam);
}

extension _$TargetClassSwitchExtension on TargetClass {
  _$BaseOtherBaseSwitchWrapper<T> $switch<T>(
      Base baseParam, OtherBase otherBaseParam) {
    return _$BaseOtherBaseSwitchWrapper<T>(baseParam, otherBaseParam);
  }
}

abstract class _$TargetClassSwitcherWithDefault<T> {
  T $switch(Base base, OtherBase otherBase) {
    return _$BaseOtherBaseSwitchWrapper<T>(base, otherBase)(
        aOtherA, aOtherB, bOtherA, bOtherB);
  }

  T defaultValueA() {
    return defaultValue();
  }

  T defaultValueB() {
    return defaultValue();
  }

  T defaultValue();
  T aOtherA(A a, OtherA otherA) {
    return defaultValueA();
  }

  T aOtherB(A a, OtherB otherB) {
    return defaultValueA();
  }

  T bOtherA(B b, OtherA otherA) {
    return defaultValueB();
  }

  T bOtherB(B b, OtherB otherB) {
    return defaultValueB();
  }
}

abstract class _$TargetClassSwitcher<T> {
  T $switch(Base base, OtherBase otherBase) {
    return _$BaseOtherBaseSwitchWrapper<T>(base, otherBase)(
        aOtherA, aOtherB, bOtherA, bOtherB);
  }

  T aOtherA(A a, OtherA otherA);
  T aOtherB(A a, OtherB otherB);
  T bOtherA(B b, OtherA otherA);
  T bOtherB(B b, OtherB otherB);
}
''')
@ClassSwitch(classes: [Base, OtherBase])
class TargetClass {}

abstract class Base {}

class A extends Base {}

class B extends Base {}

abstract class OtherBase {}

class OtherA extends OtherBase {}

class OtherB extends OtherBase {}
