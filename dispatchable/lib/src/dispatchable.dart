class Dispatchable {
  final List<Type> classes;
  final String methodPrefix;
  final String methodSeparator;

  const Dispatchable(
      {this.classes = const [],
      this.methodSeparator = '',
      this.methodPrefix = ''});
}
