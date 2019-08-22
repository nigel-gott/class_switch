import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:class_switch_annotation/class_switch_annotation.dart';

class ClassSwitchCodeBuilder {
  final ClassElement _baseClass;
  final List<ClassElement> _subClasses;
  final bool _withDefault;

  String get _baseClassName => _baseClass.name;

  List<String> get _subClassNames =>
      _subClasses.map((ClassElement e) => e.name).toList();

  factory ClassSwitchCodeBuilder.fromAnnotation(
      Element baseClassElement, LibraryReader libraryReader, bool withDefault) {
    if (baseClassElement is ClassElement) {
      final List<ClassElement> subClasses = libraryReader.classes
          .where((s) => s.supertype.element == baseClassElement)
          .toList();
      return ClassSwitchCodeBuilder._withClassElements(
          baseClassElement, subClasses, withDefault);
    } else {
      throw Exception(
          "Only class's can be annotated with @class_switch, incorrectly found $baseClassElement annotated with it!");
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
    final acceptFunctionParameterName = _lowerFirstChar(_baseClassName) + "Instance";
    return """
      T accept$_baseClassName($_baseClassName $acceptFunctionParameterName) {
        return ${_withDefault ? _switcherClassName + "." : ""}${_switcherFunctionName()}($_methodParameters)($acceptFunctionParameterName);
      }
    """;
  }

  String get _methodParameters => _classesAcceptedBySwitcher.map(_classMethodName).join(",");

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

  List<String> get _classesAcceptedBySwitcher => [..._subClassNames, if(!_baseClass.isAbstract) _baseClassName];


  String _switcherFunctionName() =>
      "${_lowerFirstChar(_baseClassName)}Switcher";

  String _generateSwitcherFunction() {
    final String subClassMethodParameters =
        _classesAcceptedBySwitcher.map((e) => "T Function($e) ${_classMethodName(e)}").join(",");

    final String firstSubClass = _classesAcceptedBySwitcher[0];
    final List<String> remainingSubClassNames = _classesAcceptedBySwitcher.sublist(1);

    var baseClassParameterName = _lowerFirstChar(_baseClassName) + "Instance";

    var firstIf = _ifStatement(
        baseClassParameterName, firstSubClass, _classMethodName(firstSubClass));
    var elseIfs = remainingSubClassNames
        .map((e) => _elseIfStatement(baseClassParameterName, e, _classMethodName(e)))
        .join();

    return """
    static T Function($_baseClassName) ${_switcherFunctionName()}<T>($subClassMethodParameters) {
      return ($baseClassParameterName) {
    $firstIf
    $elseIfs
    else {
      throw UnimplementedError(
          "Unknown class given to switcher: \$$baseClassParameterName. subClass code generation has done something incorrectly. ");
    }
      };
    }
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

class ClassSwitchGenerator extends Generator {
  static const TypeChecker ClassSwitchAnnotationTypeChecker =
      TypeChecker.fromRuntime(ClassSwitch);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    var codeElementsAnnotatedWithClassSwitch =
        library.annotatedWith(ClassSwitchAnnotationTypeChecker);
    if (codeElementsAnnotatedWithClassSwitch.isEmpty) {
      return "";
    }
    return codeElementsAnnotatedWithClassSwitch
        .expand((e) => [
          ClassSwitchCodeBuilder.fromAnnotation(e.element, library, true).generateCodeForClassAndSubClasses(),
      ClassSwitchCodeBuilder.fromAnnotation(e.element, library, false).generateCodeForClassAndSubClasses(),
    ])
        .join();
  }
}
