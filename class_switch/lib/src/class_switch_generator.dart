import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:class_switch/src/class_switch_base.dart';

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
    final acceptFunctionParameterName = _lowerFirstChar(_baseClassName);
    final subClassMethodNamesAsParameterList =
        _subClassNames.map(_subClassAbstractMethodName).join(",");
    return """
      T accept$_baseClassName($_baseClassName $acceptFunctionParameterName) {
        return ${_withDefault ? _switcherClassName + "." : ""}${_switcherFunctionName()}($subClassMethodNamesAsParameterList)($acceptFunctionParameterName);
      }
    """;
  }

  String _generateSubClassMethods() {
    return _subClassNames.map((subClassName) {
      final String methodName = _subClassAbstractMethodName(subClassName);
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

  String _subClassAbstractMethodName(String subClassClassName) =>
      _lowerFirstChar(subClassClassName);

  String _switcherFunctionName() =>
      "${_lowerFirstChar(_baseClassName)}Switcher";

  String _generateSwitcherFunction() {
    final String subClassMethodParameters =
        _subClassNames.map((e) => "T Function($e) ${_switcher(e)}").join(",");

    final String firstSubClass = _subClassNames[0];
    final List<String> remainingSubClassNames = _subClassNames.sublist(1);

    var baseClassParameterName = _lowerFirstChar(_baseClassName);

    var firstIf = _ifStatement(
        baseClassParameterName, firstSubClass, _switcher(firstSubClass));
    var elseIfs = remainingSubClassNames
        .map((e) => _elseIfStatement(baseClassParameterName, e, _switcher(e)))
        .join();

    return """
    static Function($_baseClassName) ${baseClassParameterName}Switcher<T>($subClassMethodParameters) {
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

  String _switcher(String type) => "${_lowerFirstChar(type)}";

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
