import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

part 'class_switch_multi_usage_test.g.dart';

abstract class Event {}

class OpenEvent extends Event {}

class CloseEvent extends Event {}

abstract class State {}

class RunningState extends State {}

class LoadingState extends State {}

@ClassSwitch(classes: [State, Event])
class MyClass {}

@ClassSwitch(
    prefix: '\$outer',
    classes: [State, Event],
    syntaxMode:
        SYNTAX_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION)
class MyClass2 {}

@ClassSwitch(
    prefix: '\$single',
    classes: [State, Event],
    syntaxMode: SYNTAX_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES)
class MyClass3 {}

class MyClassSwitcher extends _$MyClassSwitcher<String> {
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
  group('Tests showing class_switch library usage with multiple classes.', () {
    group(
        'Annotating a class with @ClassSwitch() a list of sub types will '
        'generate:', () {
      test(
          'A class with abstract methods for each sub-class and a method '
          'dispatching to the corresponding abstract subtype method.', () {
        var myClassSwitcher = MyClassSwitcher();
        expect(myClassSwitcher.$switch(RunningState(), OpenEvent()),
            'Running Open');
        expect(myClassSwitcher.$switch(RunningState(), CloseEvent()),
            'Running Close');
        expect(myClassSwitcher.$switch(LoadingState(), OpenEvent()),
            'Loading Open');
        expect(myClassSwitcher.$switch(LoadingState(), CloseEvent()),
            'Loading Close');
      });
      test(
          'An extension method not utilizing this to switch with on the target '
          'class', () {
        var state = LoadingState();
        var event = OpenEvent();

        // @ClassSwitch(syntax_mode:...) can take three different values, each one
        // generating a different api/syntax for performing a class switch.
        //
        // These modes do no affect the Switcher classes.
        //
        // Each of these modes provide the same compile time guarantees such that adding/removing sub types will
        // cause compiler errors about missing cases. However none provide a good autocomplete experience when a
        // new sub type is added/removed as you have to manually change the parameters in intellij. Instead
        // implement a switcher class to get autocomplete support as you can ctrl-enter "implement missing methods"
        // when new cases are added, or when a case is removed a warning will be displayed on the @override animation
        // where you can ctrl-enter to delete the case.
        //
        // By default WRAPPER_CLASS is enabled as it provides in my opinion a
        // good autocomplete experience combined with the easiest to read code.
        // However there are two other options also show below:
        //   - METHOD_TAKES_BOTH_INSTANCES_AND_CASES: provides the best autocomplete experience in intellij, but imo slightly harder to read code.
        //   - METHOD_TAKES_INSTANCES_RETURNING_CASE_FUNCTION: conceptually the simplest mode, however intellij provides no autocomplete help at all. Looks good also.

        // SYNTAX_MODE: WRAPPER_CLASS
        // The switch function returns a callable 'switch' Class wrapping the instance parameters (like a closure) which has a call method (can type .call to get autocomplete and delete after manually)

        // Force dartfmt to give each case a newline with a blank comment after the first case
        var r = $switchStateEvent(state, event)(
            (rs, oe) => 'rsOe', //
            (rs, ce) => 'rsCe',
            (ls, oe) => 'lsOe',
            (ls, ce) => 'lsCe');
        expect(r, 'lsOe');

        // Also provides a cases method which is exactly the same as call if you prefer for readability.
        r = $switchStateEvent(state, event).cases(
            (rs, oe) => '1', //
            (rs, ce) => '2',
            (ls, oe) => '3',
            (ls, ce) => '3');
        expect(r, '3');

        // Or you can just use the Class directly (the function above provides a better autocomplete experience however)
        r = $SwitchStateEvent(state, event)(
            (rs, oe) => 'a', //
            (rs, ce) => 'b',
            (ls, oe) => 'c',
            (ls, ce) => 'd');
        expect(r, 'c');

        // SYNTAX_MODE: METHOD_TAKES_BOTH_INSTANCES_AND_CASES

        // Or using the everything at once method. This provides the best intellij autocomplete experience
        // as selecting the method and hitting enter instantly generates the instances + case clauses in one key press.
        // However you the syntax looks less like a switch statement and is possibly less readable this way.
        r = $singleStateEvent(
            state,
            event,
            (runningState, openEvent) => 1,
            (runningState, closeEvent) => 2,
            (loadingState, openEvent) => 3,
            (loadingState, closeEvent) => 4);
        expect(r, 3);

        // SYNTAX_MODE: METHOD_TAKES_INSTANCES_RETURNING_CASE_FUNCTION
        // Or finally just using anonymous methods which has no autocomplete support in intellij at all currently (there is an open issue).
        r = $outerStateEvent(state, event)(
            (runningState, openEvent) => true,
            (runningState, closeEvent) => true,
            (loadingState, openEvent) => false,
            (loadingState, closeEvent) => true);
        expect(r, false);
      });
    });
  });
}
