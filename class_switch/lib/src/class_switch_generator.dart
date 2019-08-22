import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:class_switch/src/class_switch_base.dart';

class ClassSwitchCodeBuilder {
  final ClassElement _baseClass;
  final List<ClassElement> _subClasses;

  factory ClassSwitchCodeBuilder.fromAnnotation(
      Element baseClassElement, LibraryReader libraryReader) {
    if (baseClassElement is ClassElement) {
      final List<ClassElement> subClasses = libraryReader.classes
          .where((s) => s.supertype.element == baseClassElement)
          .toList();
      return ClassSwitchCodeBuilder._withClassElements(
          baseClassElement, subClasses);
    } else {
      throw Exception(
          "Only class's can be annotated with @class_switch, incorrectly found $baseClassElement annotated with it!");
    }
  }

  ClassSwitchCodeBuilder._withClassElements(this._baseClass, this._subClasses);

  String generateCodeForClassAndSubClasses() {
    final String baseClassName = _baseClass.name;
    final subClassNames = _subClasses.map((e) => e.name).toList();
    return """
    ${_generateSwitcherClass(baseClassName, subClassNames)}
    ${_generateSwitcherClassWithDefaults(baseClassName, subClassNames)}
    """;
  }

  String _generateSwitcherClass(
      String baseClassName, List<String> subClassNames) {
    final String switcherFunction =
    _generateSwitcherFunction(baseClassName, subClassNames);
    final String subClassMethodDefinitions =
    _generateAbstractsubClassMethods(subClassNames);
    final String switcherAcceptFunction =
    _generateSwitcherAcceptFunction(baseClassName, subClassNames);
    return """
    abstract class ${baseClassName}Switcher<T> {
      $switcherFunction
      $switcherAcceptFunction 
       
      $subClassMethodDefinitions
    }
    """;
  }

  String _generateSwitcherAcceptFunction(
      String baseClassName, List<String> subClassNames) {
    final acceptFunctionParameterName = _lowerFirstChar(baseClassName);
    final subClassMethodNamesAsParameterList =
    subClassNames.map(_subClassAbstractMethodName).join(",");
    return """
      T accept$baseClassName($baseClassName $acceptFunctionParameterName) {
        return ${_switcherFunctionName(baseClassName)}($subClassMethodNamesAsParameterList)($acceptFunctionParameterName);
      }
    """;
  }

  String _generateAbstractsubClassMethods(List<String> subClassNames) {
    return subClassNames.map((subClassName) {
      final String methodName = _subClassAbstractMethodName(subClassName);
      final String subClassParameterName = methodName;
      return """T $methodName(${subClassName} $subClassParameterName);""";
    }).join("\n");
  }

  String _subClassAbstractMethodName(String subClassClassName) =>
      _lowerFirstChar(subClassClassName);

  String _switcherFunctionName(String baseClass) =>
      "${_lowerFirstChar(baseClass)}Switcher";

  String _generateSwitcherFunction(String baseClass, List<String> subClassNames) {
    final String subClassMethodParameters =
    subClassNames.map((e) => "T Function($e) ${_switcher(e)}").join(",");

    final String firstsubClass = subClassNames[0];
    final List<String> remainingsubClassNames = subClassNames.sublist(1);

    var baseClassParameterName = _lowerFirstChar(baseClass);

    var firstIf = _ifStatement(
        baseClassParameterName, firstsubClass, _switcher(firstsubClass));
    var elseIfs = remainingsubClassNames
        .map((e) => _elseIfStatement(baseClassParameterName, e, _switcher(e)))
        .join();

    return """
    static Function($baseClass) ${baseClassParameterName}Switcher<T>($subClassMethodParameters) {
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

  String _generateSwitcherClassWithDefaults(
      String baseClass, List<String> subClassNames) {
    final String baseClassArgument = _lowerFirstChar(baseClass);
    final String baseClassSwitcherClass = _switcherFunctionName(baseClass);
    final String subClassMethodNames =
    subClassNames.map((sub) => _subClassAbstractMethodName(sub)).join(",");
    final String subClassMethodDefinitions = subClassNames.map((sub) {
      final String subClassMethodName = _subClassAbstractMethodName(sub);
      return """T $subClassMethodName(${sub} $subClassMethodName){
        return defaultValue();
      }""";
    }).join("\n");
    return """
    abstract class ${baseClass}SwitcherWithDefault<T> {
      T accept$baseClass($baseClass $baseClassArgument) {
        return ${baseClass}Switcher.${baseClassSwitcherClass}($subClassMethodNames)($baseClassArgument);
      }
      
      T defaultValue();
       
      $subClassMethodDefinitions
    }
    """;
  }
}

class ClassSwitchGenerator extends Generator {
  static const TypeChecker ClassSwitchAnnotationTypeChecker =
      TypeChecker.fromRuntime(ClassSwitch);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return makesubClasss(library);
  }

  String makesubClasss(LibraryReader library) {
    var codeElementsAnnotatedWithClassSwitch =
        library.annotatedWith(ClassSwitchAnnotationTypeChecker);
    if (codeElementsAnnotatedWithClassSwitch.isEmpty) {
      return "";
    }
    return codeElementsAnnotatedWithClassSwitch
        .map((e) => ClassSwitchCodeBuilder.fromAnnotation(e.element, library).generateCodeForClassAndSubClasses())
        .join();
  }


}
