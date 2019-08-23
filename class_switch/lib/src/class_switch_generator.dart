import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:class_switch_annotation/class_switch_annotation.dart';
import 'package:source_gen/source_gen.dart';

class ClassSwitchGenerator extends Generator {
  static const TypeChecker ClassSwitchAnnotationTypeChecker =
      TypeChecker.fromRuntime(ClassSwitch);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final List<AnnotatedElement> codeElementsAnnotatedWithClassSwitch =
        library.annotatedWith(ClassSwitchAnnotationTypeChecker).toList();
    if (codeElementsAnnotatedWithClassSwitch.isEmpty) {
      return "";
    }
    return codeElementsAnnotatedWithClassSwitch
        .map((e) => generateForElement(e.element, library))
        .join();
  }

  String generateForElement(Element e, LibraryReader library) {
    return [
      ClassSwitchCodeBuilder.fromAnnotation(e, library, true)
          .generateCodeForClassAndSubClasses(),
      ClassSwitchCodeBuilder.fromAnnotation(e, library, false)
          .generateCodeForClassAndSubClasses(),
    ].join("\n");
  }
}

class ClassSwitchCodeBuilder {
  final ClassElement _baseClass;
  final List<ClassElement> _subClasses;
  final bool _withDefault;

  String get _baseClassName => _baseClass.name;

  List<String> get _subClassNames =>
      _subClasses.map((ClassElement e) => e.name).toList();

  factory ClassSwitchCodeBuilder.fromAnnotation(
      Element element, LibraryReader libraryReader, bool withDefault) {
    if (element is ClassElement && !element.isEnum) {
      final List<ClassElement> subClasses = libraryReader.classes
          .where((s) => s.supertype.element == element)
          .toList();
      return ClassSwitchCodeBuilder._withClassElements(
          element, subClasses, withDefault);
    } else {
      throw InvalidGenerationSourceError(
          "@class_switch can only be used to annotate a class.",
          todo: "Remove @class_switch annotation from the offending element.",
          element: element);
    }
  }

  ClassSwitchCodeBuilder._withClassElements(
      this._baseClass, this._subClasses, this._withDefault);

  get _switcherClassName => _baseClassName + "Switcher";

  String generateCodeForClassAndSubClasses() {
    return """
    ${_generateSwitcherClass()}
    """;
  }

  String _generateSwitcherClass() {
    return """
    abstract class ${_switcherClassName}${_withDefault ? "WithDefault" : ""}<T> {
      ${_withDefault ? "" : _generateSwitcherFunction()}
      ${_generateSwitcherAcceptFunction()} 
      ${_withDefault ? _generateDefaultMethod() : ""}
       
      ${_generateSubClassMethods()}
    }
    """;
  }

  String _generateSwitcherAcceptFunction() {
    final acceptFunctionParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";
    return """
      T accept$_baseClassName($_baseClassName $acceptFunctionParameterName) {
        return ${_withDefault ? _switcherClassName + "." : ""}${_switcherFunctionName()}($_methodParameters)($acceptFunctionParameterName);
      }
    """;
  }

  String get _methodParameters =>
      _classesAcceptedBySwitcher.map(_classMethodName).join(",");

  String _generateSubClassMethods() {
    return _classesAcceptedBySwitcher.map((subClassName) {
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

  List<String> get _classesAcceptedBySwitcher =>
      [..._subClassNames, if (!_baseClass.isAbstract) _baseClassName];

  String _switcherFunctionName() =>
      "${_lowerFirstChar(_baseClassName)}Switcher";

  String _generateSwitcherFunction() {
    final String subClassMethodParameters = _classesAcceptedBySwitcher
        .map((e) => "T Function($e) ${_classMethodName(e)}")
        .join(",");

    return """
    static T Function($_baseClassName) ${_switcherFunctionName()}<T>($subClassMethodParameters) {
    ${_generateSwitcherFunctionBody()}
    }
    """;
  }

  String _generateSwitcherFunctionBody() {
    final String baseClassParameterName =
        _lowerFirstChar(_baseClassName) + "Instance";
    if (_classesAcceptedBySwitcher.isEmpty) {
      throw InvalidGenerationSourceError(
          "Cannot generate a switcher for an abstract class with no sub classes.",
          todo:
              "Remove @class_switch from the offending class or implement sub classes for it.",
          element: _baseClass);
    } else {
      return """
      return ($baseClassParameterName) {
      ${_generateIfBloc()}
    else if($baseClassParameterName == null){
      throw ArgumentError("Null parameter passed to switcher.");
    } else {
      throw ArgumentError(
      "Unknown class given to switcher: \$$baseClassParameterName. Have you added a new sub class for $_baseClassName without running pub run build_runner build?. ");
    }
    };
    """;
    }
  }

  String _generateIfBloc() {
    final String firstSubClass = _classesAcceptedBySwitcher[0];
    final List<String> remainingSubClassNames =
        _classesAcceptedBySwitcher.sublist(1);
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
