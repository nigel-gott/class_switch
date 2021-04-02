import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'code_builders.dart';

class DispatchableClassGenerator {
  final List<String> _classesAcceptedByDispatcher;
  final String _baseClassName;

  String get _dispatchableClassName => _baseClassName + "Dispatcher";

  String get _dispatchableStaticFunctionName =>
      "${_lowerFirstChar(_dispatchableClassName)}";

  DispatchableClassGenerator._withClasses(
      this._baseClassName, this._classesAcceptedByDispatcher);

  factory DispatchableClassGenerator.validateAndCreate(
      ClassElement _baseClass, List<ClassElement> _subClasses) {
    _validate(_baseClass, _subClasses);
    return DispatchableClassGenerator._withClasses(_baseClass.name, [
      ..._subClasses.map((ClassElement e) => e.name),
      // Accept the BaseClass if it is possible to create an instance of it and
      // pass it to the dispatcher!
      if (!_baseClass.isAbstract) _baseClass.name
    ]);
  }

  static void _validate(
      ClassElement _baseClass, List<ClassElement> _subClasses) {
    if (_baseClass.isEnum) {
      throw InvalidGenerationSourceError(
          "@dispatchable can only be used to annotate a class.",
          todo: "Remove @dispatchable annotation from the offending element.",
          element: _baseClass);
    }
    if (_baseClass.isAbstract && _subClasses.isEmpty) {
      throw InvalidGenerationSourceError(
          "Cannot generate a dispatchable for an abstract class with no sub "
          "classes.",
          todo:
              "Remove @dispatchable from the offending class or implement sub "
              "classes for it.",
          element: _baseClass);
    }
  }

  String generateDispatcherClass() {
    return _generateDispatcherClass(true);
  }

  String generateDefaultDispatcherClass() {
    return _generateDispatcherClass(false);
  }

  String _generateDispatcherClass(bool withDefault) {
    String className =
        _dispatchableClassName + (withDefault ? "WithDefault" : "");
    ClassBuilder classBuilder = ClassBuilder(className);
    _addAcceptMethod(classBuilder);
    if (withDefault) {
      _addAbstractDefaultMethod(classBuilder);
    } else {
      _addStaticDispatchMethod(classBuilder);
    }
    _addSubClassMethods(withDefault, classBuilder);
    return classBuilder.build();
  }

  void _addSubClassMethods(bool withDefault, ClassBuilder classBuilder) {
    _classesAcceptedByDispatcher.forEach((subClassName) {
      String methodName = _classMethodName(subClassName);
      MethodBuilder builder = classBuilder.addMethod(methodName)
        ..withParameter("$subClassName $methodName")
        ..andReturns("T");
      if (withDefault) {
        builder.withBody("return defaultValue();");
      } else {
        builder.whichIsAbstract();
      }
    });
  }

  void _addAbstractDefaultMethod(ClassBuilder classBuilder) {
    classBuilder.addMethod("defaultValue")
      ..whichIsAbstract()
      ..andReturns("T");
  }

  void _addAcceptMethod(ClassBuilder classBuilder) {
    String acceptFunctionParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";
    String parameters =
        _classesAcceptedByDispatcher.map(_classMethodName).join(",");
    String body =
        "return $_dispatchableClassName.$_dispatchableStaticFunctionName"
        "($parameters)($acceptFunctionParameterName);";
    classBuilder.addMethod("accept$_baseClassName")
      ..withParameter("$_baseClassName $acceptFunctionParameterName")
      ..withBody(body)
      ..andReturns("T");
  }

  void _addStaticDispatchMethod(ClassBuilder classBuilder) {
    classBuilder.addMethod(_dispatchableStaticFunctionName)
      ..whichIsStatic()
      ..whichHasATemplateParameter("T")
      ..withParameters(_classesAcceptedByDispatcher
          .map((e) => "T Function($e) ${_classMethodName(e)}"))
      ..withBody(_generateDispatcherFunctionBody())
      ..andReturns("T Function($_baseClassName)");
  }

  String _generateDispatcherFunctionBody() {
    final String baseClassParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";
    return """
      return ($baseClassParameterName) {
      ${_generateIfBloc()}
    else if($baseClassParameterName == null){
      throw ArgumentError("Null parameter passed to dispatchable.");
    } else {
      throw ArgumentError(
      "Unknown class given to dispatchable: \$$baseClassParameterName. Have you 
      added a new sub class for $_baseClassName without running pub run 
      build_runner build?. ");
    }
    };
    """;
  }

  String _generateIfBloc() {
    final String firstSubClass = _classesAcceptedByDispatcher[0];
    final List<String> remainingSubClassNames =
        _classesAcceptedByDispatcher.sublist(1);
    final String baseClassParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";

    final String firstIf = _ifStatement(
        baseClassParameterName, firstSubClass, _classMethodName(firstSubClass));
    final String elseIfs = remainingSubClassNames
        .map((e) =>
            _elseIfStatement(baseClassParameterName, e, _classMethodName(e)))
        .join();
    return """
    $firstIf
    $elseIfs
    """;
  }

  String _classMethodName(String type) => "${_lowerFirstChar(type)}";

  String _ifStatement(String param, String type, String handler) => """
  if($param is $type) {
    return $handler($param);
  }
  """;

  String _elseIfStatement(String param, String type, String handler) => """
  else if($param is $type) {
    return $handler($param);
  }
  """;

  String _lowerFirstChar(String e) => e.replaceRange(0, 1, e[0].toLowerCase());
}
