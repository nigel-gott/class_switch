import 'package:meta/meta.dart';

enum DSL_MODE {
  /// The default mode. In [DSL_MODE.WRAPPER_CLASS] the generated
  /// $switchXXYY(instances...) functions will return a callable class wrapping
  /// the provided instances. This class can then be directly called providing
  /// case functions to perform a switch over the instances like so:
  ///
  /// ```dart
  /// // WRAPPER_CLASS is the default mode so you don't need to provide
  /// // any options to @ClassSwitch.
  /// @ClassSwitch(options:ClassSwitchOptions(dslMode:WRAPPER_CLASS))
  /// abstract class Base {}
  /// class A extends Base {}
  /// class B extends Base {}
  ///
  /// // The above will generate a function you can use like so:
  /// $switchBase(A())(
  ///   (a) => 1, //
  ///   (b) => 2);
  ///
  /// // Explicitly typing .call will autocomplete all of the case functions for
  /// // you in intellij! After which you can delete .call .
  /// $switchBase(A()).call(
  ///   (a) => 1, //
  ///   (b) => 2);
  ///
  /// // A cases method is also provided which is exactly the same as .call
  /// // but provides a more readable api and also works nicely with
  /// // autocomplete.
  /// $switchBase(A()).cases(
  ///   (a) => 1, //
  ///   (b) => 2)
  /// ```
  WRAPPER_CLASS,

  /// In [DSL_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES] the generated
  /// $switchXXYY functions take both the instances and the cases in one
  /// method call and immediately performs the switch and returns the result.
  ///
  /// This provides the best autocomplete experience as intellij can generate
  /// all of the instance parameters and case parameters in one go.
  /// However the API looks less like a traditional switch statement and so
  /// might be seen as less readable or obvious what is happening.
  ///
  /// ```dart
  /// @ClassSwitch(options:ClassSwitchOptions(dslMode:SINGLE_METHOD_WITH_INSTANCES_AND_CASES))
  /// abstract class Base {}
  /// class A extends Base {}
  /// class B extends Base {}
  ///
  /// // The above will generate a function you can use like so:
  /// $switchBase(
  ///   A(),
  ///   (a) => 1,
  ///   (b) => 2);
  /// ```
  SINGLE_METHOD_WITH_INSTANCES_AND_CASES,

  /// In [DSL_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION] the generated
  /// $switchXXYY functions take the instances and return an anonymous function
  /// which then takes the case functions and performs the switch.
  ///
  /// Intellij provides no help with autocompleting switch functions generated
  /// in this mode. However it does generate the simplest API out of the modes
  /// and perhaps in the future or in other IDE's autocomplete will help out
  /// more.
  ///
  /// ```dart
  /// @ClassSwitch(options:ClassSwitchOptions(dslMode:OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION))
  /// abstract class Base {}
  /// class A extends Base {}
  /// class B extends Base {}
  ///
  /// // The above will generate a function you can use like so:
  /// $switchBase(A())(
  ///   (a) => 1, //
  ///   (b) => 2);
  /// ```
  OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION
}

/// Annotate a class with @ClassSwitch to get class switching helper code
/// generated for you.
///
/// The annotated class will have a .$switch extension function created on it.
/// The annotated classes name will be used to generate two mixin classes called
/// _${AnnotatedClassName}Switcher and _${AnnotatedClassName}SwitcherWithDefault
class ClassSwitch {
  /// Explicitly provide a list of base classes to generate a switcher for.
  /// When multiple are provided then the switch functions will take an instance
  /// of each base class in turn and then require case functions for every
  /// possible combination of sub-types.
  ///
  /// The annotated class must be explicitly provided in this list if you still
  /// want the class switches to take it as a parameter. Otherwise you can
  /// not include it and the generated switch code will only be for the provided
  /// classes, however the extension function will still be on the annotated
  /// class and the mixin classes will still be named after the annotated class.
  final List<Type> classes;

  /// Experimental options for configuring how class switch generates code.
  @experimental
  final ClassSwitchOptions options;

  const ClassSwitch(
      {this.classes = const [], this.options = const ClassSwitchOptions()});
}

/// Various experimental options allowing deep customization of the generated
/// class switch code. These options aren't global and only affect the generated
/// code for the annotation where they are provided. If you have a common set of
/// options you use regularly create an alias for them to save yourself typing
/// time!
///
/// FEEDBACK WANTED: Please let me know if you find any of these options useful
/// and which you prefer in [our Discord](https://discord.gg/5tjXhYJxdA) or
/// on [this github issue](https://github.com/nigel-gott/class_switch/issues/1).
///
/// In these early dev releases a wide range of options are included and the
/// library does not yet try to take an opinionated stance on which API is best
/// or which of the options should not be customizable. However expect these
/// options to radically change, be removed, have functionality combined etc in
/// future more stable releases after user feedback on the API.
@experimental
class ClassSwitchOptions {
  /// When annotating the same class multiple times you will need to provide
  /// different `switchFunctionPrefix`s to prevent function name collisions.
  final String switchFunctionPrefix;

  /// For the generated Switcher classes this is an optional prefix that will be
  /// applied to the names of all of the generated abstract sub type methods.
  ///
  /// For example `abstractMethodPrefix:'on'` results in abstract methods
  /// named like `onEventA`. A full example is shown below:
  /// ```dart
  /// @ClassSwitch(options:ClassSwitchOptions(abstractMethodPrefix:"on"))
  /// abstract class Event {}
  /// class EventA extends Event {}
  /// class EventB extends Event {}
  ///
  /// // The above will generate a Switcher which when mixed in has abstract
  /// // methods named using the provided abstractMethodPrefix:
  /// class MyEventHandler with _$EventSwitcher<int> {
  ///   @override
  ///   int onEventA(EventA eventA) => 1;
  ///
  ///   @override
  ///   int onEventB(EventB eventB) => 2;
  /// }
  /// ```
  ///
  /// This is useful for when you want to create a more readable API for one of
  /// your switcher classes.
  final String abstractMethodPrefix;

  /// For the generated Switcher classes this is an optional separator that will
  /// be placed between the sub type names in the abstract method names.
  ///
  /// For example `abstractMethodSubTypeSeparator: 'With'` results in abstract
  /// methods named like `subTypeAWithOtherClassSubTypeA`. A full example is
  /// shown below:
  /// ```dart
  /// abstract class Event {}
  /// class EventA extends Event {}
  /// class EventB extends Event {}
  ///
  /// abstract class State {}
  /// class StateA extends State {}
  /// class StateB extends State {}
  ///
  /// // This will generate a Switcher which when mixed in has abstract
  /// // methods named using the provided abstractMethodSubTypeSeparator:
  /// @ClassSwitch(
  ///   classes: [State, Event],
  ///   options: ClassSwitchOptions(abstractMethodSubTypeSeparator:"With"))
  /// class MyStateAndEventHandler with _$MyStateAndEventHandlerSwitcher {
  ///   @override
  ///   int stateAWithEventA(StateA stateA, EventA eventA) => 1;
  ///   @override
  ///   int stateAWithEventB(StateA stateA, EventB eventB) => 2;
  ///   @override
  ///   int stateBWithEventA(StateB stateB, EventA eventB) => 3;
  ///   @override
  ///   int stateBWithEventB(StateB stateB, EventB eventB) => 4;
  /// }
  ///
  /// ```
  ///
  /// This is useful for when you want to create a more readable API for one of
  /// your switcher classes when switching over multiple classes at once.
  final String abstractMethodSubTypeSeparator;

  /// The dslMode changes the API of the generated classes and functions
  /// for this particular annotation. Multiple different modes are provided
  /// currently as each has different trade-offs with readability vs their
  /// autocomplete experience.
  ///
  /// All of these modes change not only the globally generated $switchXXYY
  /// functions for this annotation, but also the extension functions and
  /// switcher classes in the same way to match the mode.
  final DSL_MODE dslMode;

  const ClassSwitchOptions(
      {this.abstractMethodSubTypeSeparator = '',
      this.abstractMethodPrefix = '',
      this.switchFunctionPrefix = '\$switch',
      this.dslMode = DSL_MODE.WRAPPER_CLASS});
}

class MultiDispatch {
  const MultiDispatch();
}

const M = MultiDispatch();
