import 'package:dispatchable/dispatchable.dart';
import 'package:test/test.dart';

part 'dispatchable_edge_cases_test.g.dart';

@Dispatchable()
class NonAbstractBaseClass {}

class FirstSubClassOfNonAbstractBaseClass extends NonAbstractBaseClass {}

class SecondSubClassOfNonAbstractBaseClass extends NonAbstractBaseClass {}

@Dispatchable()
abstract class BaseClass {}

class FirstSubType extends BaseClass {}

class SecondSubType extends BaseClass {}

class FirstSubTypeOfFirstSubType extends FirstSubType {}

class SecondSubTypeOfFirstSubType extends FirstSubType {}

@Dispatchable()
class ClassWithNoSubClasses {}

void main() {
  group('Tests showing dispatchable library behaviour in edge cases.', () {
    test(
        'Generates an extra handler function for the base class type if it is '
        'not abstract.', () {
      var func =
          _$NonAbstractBaseClassDispatcher.acceptFunc<String>((firstSubType) {
        return 'first';
      }, (secondSubType) {
        return 'second';
      }, (nonAbstractBaseClass) {
        return 'base';
      });
      expect(func(FirstSubClassOfNonAbstractBaseClass()), 'first');
      expect(func(SecondSubClassOfNonAbstractBaseClass()), 'second');
      expect(func(NonAbstractBaseClass()), 'base');
    });
    test(
        'Only generates for immediate sub-classes of the annotated type and '
        'ignores any sub-classes of the sub-classes', () {
      var func = _$BaseClassDispatcher.acceptFunc<String>((firstSubType) {
        return 'first';
      }, (secondSubType) {
        return 'second';
      });
      expect(func(FirstSubType()), 'first');
      expect(func(SecondSubType()), 'second');
      expect(func(FirstSubTypeOfFirstSubType()), 'first');
      expect(func(SecondSubTypeOfFirstSubType()), 'first');
    });
    test(
        'Generates with a single dispatcher for the base class when non '
        'abstract base class with no sub classes is annotated', () {
      final function =
          _$ClassWithNoSubClassesDispatcher.acceptFunc((classWithNoSubClasses) {
        return 1;
      });
      expect(function(ClassWithNoSubClasses()), 1);
    });
  });
}
