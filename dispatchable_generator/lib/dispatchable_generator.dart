/// Dispatchable generates dispatchers for all sub-classes of an annotated class
/// , using these provide compile time guarantees that all possible sub-classes
/// have been dealt with.
///
/// A dispatcher takes an instance of a class and calls a user defined function
/// depending on which sub type it is.
/// Dispatchable will generate for a class annotated with @dispatchable:
/// * An abstract Dispatcher class which has:
/// ** Abstract sub-class methods for each possible sub-class found in the same
///    file as the annotated class.
/// ** An accept method which takes an instance of the annotated class and calls
///    the appropriate sub-class method given the type of the instance.
/// * A static Dispatcher method on the previous Dispatcher class which takes a
///   handler method for each sub-class and returns a function which takes an
///   instance of the class and calls the corresponding handler method.
/// * An abstract DispatcherWithDefaults class which has:
/// ** An abstract default method allowing you to set a default for all types
///    where you have not overridden the sub-class method.
/// ** sub-class methods for each possible sub-class found in the same file as
///    the annotated class, which will return the result of the default method
///    unless overridden.
///
///
/// `
///@dispatchable
///abstract class Fruit {}
///class Apple extends Fruit {}
///class Orange extends Fruit {}
///`
library dispatchable_generator;

export 'package:dispatchable_generator/src/dispatchable_generator.dart';
