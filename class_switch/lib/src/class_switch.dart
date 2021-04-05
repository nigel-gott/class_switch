enum SYNTAX_MODE {
  WRAPPER_CLASS,
  SINGLE_METHOD_WITH_INSTANCES_AND_CASES,
  OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION
}

class ClassSwitch {
  final List<Type> classes;
  final String prefix;
  final String methodPrefix;
  final String methodSeparator;
  final SYNTAX_MODE syntaxMode;

  const ClassSwitch(
      {this.classes = const [],
      this.methodSeparator = '',
      this.methodPrefix = '',
      this.prefix = '\$switch',
      this.syntaxMode = SYNTAX_MODE.WRAPPER_CLASS});
}
