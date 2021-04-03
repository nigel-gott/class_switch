import 'package:dispatchable/dispatchable.dart';
import 'package:test/test.dart';

part 'dispatchable_multi_usage_test.g.dart';

abstract class Event {}

class OpenEvent extends Event {}

class CloseEvent extends Event {}

abstract class State {}

class RunningState extends State {}

class LoadingState extends State {}

@Dispatchable(classes: [State, Event])
class MyClass extends _$MyClassDispatcher<String> {
  @override
  String runningStateOpenEvent(RunningState state, OpenEvent event) {
    return 'Running Open';
  }

  @override
  String runningStateCloseEvent(RunningState state, CloseEvent event) {
    return 'Running Close';
  }

  @override
  String loadingStateOpenEvent(LoadingState state, OpenEvent event) {
    return 'Loading Open';
  }

  @override
  String loadingStateCloseEvent(LoadingState state, CloseEvent event) {
    return 'Loading Close';
  }
}

void main() {
  group('Tests showing dispatchable library usage with multiple classes.', () {
    group(
        'Annotating a class with @Dispatchable() a list of sub types will '
        'generate:', () {
      test(
          'A class with abstract methods for each sub-class and a method '
          'dispatching to the corresponding abstract subtype method.', () {
        var myClass = MyClass();
        expect(myClass.accept(RunningState(), OpenEvent()), 'Running Open');
        expect(myClass.accept(RunningState(), CloseEvent()), 'Running Close');
        expect(myClass.accept(LoadingState(), OpenEvent()), 'Loading Open');
        expect(myClass.accept(LoadingState(), CloseEvent()), 'Loading Close');
      });
    });
  });
}
