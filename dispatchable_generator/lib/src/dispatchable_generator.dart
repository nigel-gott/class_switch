import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:source_gen/source_gen.dart';

class DispatchableGenerator extends Generator {
  static const TypeChecker DispatchableAnnotationTypeChecker =
      TypeChecker.fromRuntime(Dispatchable);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final List<AnnotatedElement> codeElementsAnnotatedWithDispatchable =
        library.annotatedWith(DispatchableAnnotationTypeChecker).toList();
    if (codeElementsAnnotatedWithDispatchable.isEmpty) {
      return "";
    }
    return codeElementsAnnotatedWithDispatchable
        .map((e) => generateForElement(e.element, library))
        .join();
  }

  String generateForElement(Element e, LibraryReader library) {
    return [
      DispatchableCodeBuilder.fromAnnotation(e, library, true)
          .generateCodeForClassAndSubClasses(),
      DispatchableCodeBuilder.fromAnnotation(e, library, false)
          .generateCodeForClassAndSubClasses(),
    ].join("\n");
  }
}

class DispatchableCodeBuilder {
  final ClassElement _baseClass;
  final List<ClassElement> _subClasses;
  final bool _withDefault;

  String get _baseClassName => _baseClass.name;

  List<String> get _subClassNames =>
      _subClasses.map((ClassElement e) => e.name).toList();

  factory DispatchableCodeBuilder.fromAnnotation(
      Element element, LibraryReader libraryReader, bool withDefault) {
    if (element is ClassElement && !element.isEnum) {
      final List<ClassElement> subClasses = libraryReader.classes
          .where((s) => s.supertype.element == element)
          .toList();
      return DispatchableCodeBuilder._withClassElements(
          element, subClasses, withDefault);
    } else {
      throw InvalidGenerationSourceError(
          "@dispatchable can only be used to annotate a class.",
          todo: "Remove @dispatchable annotation from the offending element.",
          element: element);
    }
  }

  DispatchableCodeBuilder._withClassElements(
      this._baseClass, this._subClasses, this._withDefault);

  get _dispatchableClassName => _baseClassName + "Dispatcher";

  String generateCodeForClassAndSubClasses() {
    return """
    ${_generateDispatcherClass()}
    """;
  }

  String _generateDispatcherClass() {
    return """
    abstract class ${_dispatchableClassName}${_withDefault ? "WithDefault" : ""}<T> {
      ${_withDefault ? "" : _generateDispatcherFunction()}
      ${_generateDispatcherAcceptFunction()} 
      ${_withDefault ? _generateDefaultMethod() : ""}
       
      ${_generateSubClassMethods()}
    }
    """;
  }

  String _generateDispatcherAcceptFunction() {
    final acceptFunctionParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";
    return """
      T accept$_baseClassName($_baseClassName $acceptFunctionParameterName) {
        return ${_withDefault ? _dispatchableClassName + "." : ""}${_dispatchableFunctionName()}($_methodParameters)($acceptFunctionParameterName);
      }
    """;
  }

  String get _methodParameters =>
      _classesAcceptedByDispatcher.map(_classMethodName).join(",");

  String _generateSubClassMethods() {
    return _classesAcceptedByDispatcher.map((subClassName) {
      final String methodName = _classMethodName(subClassName);
      final String subClassParameterName = methodName;
      if (_withDefault) {
        return """T $methodName(${subClassName} $subClassParameterName){
        return defaultValue();
      }""";
      } else {
        return """T $methodName(${subClassName} $subClassParameterName);""";
      }
    }).join("\n");
  }

  List<String> get _classesAcceptedByDispatcher =>
      [..._subClassNames, if (!_baseClass.isAbstract) _baseClassName];

  String _dispatchableFunctionName() =>
      "${_lowerFirstChar(_baseClassName)}Dispatcher";

  String _generateDispatcherFunction() {
    final String subClassMethodParameters = _classesAcceptedByDispatcher
        .map((e) => "T Function($e) ${_classMethodName(e)}")
        .join(",");

    return """
    static T Function($_baseClassName) ${_dispatchableFunctionName()}<T>($subClassMethodParameters) {
    ${_generateDispatcherFunctionBody()}
    }
    """;
  }

  String _generateDispatcherFunctionBody() {
    final String baseClassParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";
    if (_classesAcceptedByDispatcher.isEmpty) {
      throw InvalidGenerationSourceError(
          "Cannot generate a dispatchable for an abstract class with no sub classes.",
          todo:
              "Remove @dispatchable from the offending class or implement sub classes for it.",
          element: _baseClass);
    } else {
      return """
      return ($baseClassParameterName) {
      ${_generateIfBloc()}
    else if($baseClassParameterName == null){
      throw ArgumentError("Null parameter passed to dispatchable.");
    } else {
      throw ArgumentError(
      "Unknown class given to dispatchable: \$$baseClassParameterName. Have you added a new sub class for $_baseClassName without running pub run build_runner build?. ");
    }
    };
    """;
    }
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

  String _generateDefaultMethod() {
    return "T defaultValue();";
  }
}
