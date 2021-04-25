/// `class_switch` lets you switch over all the sub-classes of a class instance
/// or all possible combinations of sub-classes for multiple base class
/// instances. Using the
/// [class_switch_generator](https://pub.dev/packages/class_switch_generator)
/// library and annotations from `class_switch` you can generate functions
/// and mixins to do customizable type safe switching.
/// It pairs wonderfully with bloc helping you get rid of event and state
/// handling boilerplate. See the "Example With Bloc" section below for more.
///
/// The `class_switch` library specifically contains the annotations used by the
/// `class_switch_generator` library to generate code to switch over classes.
///
/// # How To Use
///
/// 1. Add `class_switch` as a normal dependency.
/// 2. Add `class_switch_generator` as a dev dependency.
/// 3. Annotate classes with `@ClassSwitch`.
/// 4. Ensure the sub classes of the annotated class / classes provided in the
///    annotation parameter are in the same file as the annotation.
/// 5. Include `part 'YOUR_FILE_NAME.g.dart';` in the file containing the
///    annotated class.
/// 6. Run `pub run build_runner watcher`.
/// 7. You can now switch over the annotated classes by using the generated
///    $switchXXYY functions.
///
/// # Benefits of Class Switch
///
/// Some benefits of using class_switch are:
///   - An API as close as possible to being able to switch(){} over all sub
///     classes of an annotated class.
///   - Compile time guarantees (when `pub run build_runner watcher` is
///     running) that all possible sub classes are covered by a class switch.
///   - Autocompleteable class switch statements with all the cases ready to be
///     filled in.
///   - Switcher mixin classes which provide a great autocomplete
///     experience: add a new sub-type, then on any classes implementing the
///     Mixin you can autocomplete the missing functions for the new
///     sub-type.
///   - The ability to switch over multiple different base classes, resulting in
///     switchers which have case statements for every possible combination of
///     sub-types. Super useful when used with the Bloc library!
///   - Highly customizable code generation via annotation options with multiple
///     different configurable DSLs to match your usage and make the generated
///     code as readable as possible.
///
/// # Important Caveats:
/// * When annotating a base class all of its sub-classes must be in the same
///   file as or included via the part statement in the file with the annotation
///   , otherwise class_switcher will not find sub-classes outside this and
///   the generated code will throw runtime errors if provided with these
///   unknown sub-classes.
///
/// # Example Usages
///
/// ClassSwitch will generate for a class named `BaseClass` annotated with
/// `@ClassSwitch()` (when using the default mode [DSL_MODE.CLASS_WRAPPER]):
/// ## Global $switch Functions
///   A global `$switchBaseClass` function which takes an instance of BaseClass
///   and returns a callable class which can then be provided with case
///   functions for every direct sub-class of BaseClass to perform the switch:
///   ```dart
///   @ClassSwitch()
///   abstract class BaseClass {}
///   class A extends BaseClass {}
///   class B extends BaseClass {}
///
///   // The above will generate a function you can use like so:
///   var x = $switchBaseClass(A())(
///     (a) => 1, //
///     (b) => 2);
///   assert(x == 1);
///
///   // Get autocomplete to help you by first typing `.call` or `.cases` when
///   // writing your switch!
///   var x = $switchBaseClass(A()).cases(
///     (a) => 1, //
///     (b) => 2);
///   assert(x == 1);
///   ```
/// ## Extension Methods
///   An extension method on the annotated class called `.$switch` which when no
///   additional classes are provided via the classes parameter will switch
///   using the instance. When other classes are provided you then will need to
///   provide all instances at once.
///   ```dart
///   @ClassSwitch()
///   abstract class BaseClass {}
///   class A extends BaseClass {}
///   class B extends BaseClass {}
///
///   // The above will an extension method you can use like so:
///   BaseClass anUnknownSubType = A();
///   var x = anUnknownSubType.$switch(
///     (a) => 1, //
///     (b) => 2);
///   assert(x == 1);
///   ```
/// ## Switcher Mixin Classes
/// An abstract Switcher Mixin class which has:
///   * Abstract sub-class methods for each possible sub-class found in the same
///    file as the annotated class.
///   * A `$switch` method which takes an instance of the annotated class and calls
///    the appropriate sub-class method given the type of the instance.
///
///   ```dart
///   @ClassSwitch()
///   abstract class BaseClass {}
///   class A extends BaseClass {}
///   class B extends BaseClass {}
///
///   // The above will generate a mixin you can use like so:
///   class MySwitcher extends _$BaseClassSwitcher<int>{
///     @override
///     int a(A a) => 1;
///
///     @override
///     int b(B b) => 2;
///   };
///
///   assert(MySwitcher().$switch(A()) == 1);
///   ```
/// ## Switcher Mixin Classes With Defaults
/// * An abstract SwitcherWithDefault Mixin class which has:
///   * An abstract default method allowing you to set a default for all types
///    where you have not overridden the sub-class method.
///   * sub-class methods for each possible sub-class found in the same file as
///    the annotated class, which will return the result of the default method
///    unless overridden.
///   ```dart
///   @ClassSwitch()
///   abstract class BaseClass {}
///   class A extends BaseClass {}
///   class B extends BaseClass {}
///
///   // The above will generate a mixin you can use like so:
///   class MySwitcher extends _$BaseClassSwitcherWithDefault<int>{
///     @override
///     int defaultValue() => 1;
///
///     @override
///     int b(B b) => 2;
///   };
///
///   assert(MySwitcher().$switch(A()) == 1);
///   ```
/// ## Switching over Multiple Base Classes
/// The ability for all the above features to specify multiple different
///   base classes to switch over. This is amazing for working with Bloc!
/// ### Example With Bloc
/// The example below shows how `class_switch` can be used with the Bloc library.
/// However the multi base class switch works just as well without Bloc in any
/// similar situation.
///   ```dart
///   abstract class BlocState {}
///   class StateA extends BlocState {}
///   class StateB extends BlocState {}
///
///   abstract class BlocEvent {}
///   class EventA extends BlocEvent {}
///   class EventB extends BlocEvent {}
///
///   // This will generate a mixin you can use with Bloc like so
///   @ClassSwitch(classes:[BlocState, BlocEvent])
///   class MyBloc extends Bloc<BlocEvent, BlocState> with _$MyBlocSwitcher<BlocState> {
///
///     @override
///     Stream<BlocState> mapEventToState(
///       TodoEvent event,
///     ) async* {
///       yield this.$switch(this.state, event);
///     }
///
///     @override
///     stateAEventA(StateA stateA, EventA eventA) => stateA;
///
///     @override
///     stateAEventB(StateA stateA, EventB eventB) => stateA;
///
///     @override
///     stateBEventA(StateB stateB, EventA eventA) => stateB;
///
///     @override
///     stateBEventA(StateB stateB, EventB eventB) => stateB;
///   }
///
///   // Or used as a function directly:
///   var r = $switchMyBloc(StateA(), EventA()).cases(
///     (State stateA, EventA eventA) => 'a a',
///     (State stateA, EventB eventB) => 'a b',
///     (State stateB, EventA eventA) => 'b a',
///     (State stateB, EventB eventB) => 'b b',
///   );
///   assert(r == 'a a');
///   ```
///
/// # Other provided DSLs and generation customization
/// See [DSL_MODE](https://pub.dev/documentation/class_switch/latest/class_switch/DSL_MODE-class.html)
/// and [ClassSwitchOptions](https://pub.dev/documentation/class_switch/latest/class_switch/ClassSwitchOptions-class.html)
/// for further information on the different DSL's `class_switch_generator` can
/// make and how to customize the generated code.
///
///```dart
///   @ClassSwitch()
///   abstract class BaseClass {}
///   class A extends BaseClass {}
///   class B extends BaseClass {}
///
///   // The above will generate a function you can use like so:
///   var x = $switchBaseClass(A())(
///     (a) => 1, //
///     (b) => 2);
///   assert(x == 1);
///   ```
library class_switch;

export 'package:class_switch/src/class_switch.dart';
