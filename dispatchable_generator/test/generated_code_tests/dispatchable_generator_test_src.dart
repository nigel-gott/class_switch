import 'package:dispatchable/dispatchable.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
abstract class _$BaseClassDispatcherWithDefault<T> {
  T accept(BaseClass baseClass) {
    return _$BaseClassDispatcher.acceptFunc(subClassA, subClassB)(baseClass);
  }

  T defaultValue();
  T subClassA(SubClassA subClassA) {
    return defaultValue();
  }

  T subClassB(SubClassB subClassB) {
    return defaultValue();
  }
}

abstract class _$BaseClassDispatcher<T> {
  T accept(BaseClass baseClass) {
    return _$BaseClassDispatcher.acceptFunc(subClassA, subClassB)(baseClass);
  }

  static T Function(BaseClass) acceptFunc<T>(
      T Function(SubClassA) subClassA, T Function(SubClassB) subClassB) {
    return (baseClassParam) {
      if (baseClassParam is SubClassA) {
        return subClassA(baseClassParam);
      } else if (baseClassParam is SubClassB) {
        return subClassB(baseClassParam);
      } else {
        throw ArgumentError(
            "Unknown class given to one or all of dispatchable's accept args: $baseClassParam. Have you added a new sub class for any of: BaseClass without running pub run build_runner build?. ");
      }
    };
  }

  T subClassA(SubClassA subClassA);
  T subClassB(SubClassB subClassB);
}
''')
@Dispatchable()
abstract class BaseClass {}

class SubClassA extends BaseClass {}

class SubClassB extends BaseClass {}
