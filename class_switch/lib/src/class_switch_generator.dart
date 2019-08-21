import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:class_switch/src/class_switch_base.dart';

class ClassSwitchGenerator extends Generator {
  bool first = true;

  TypeChecker get subtypeChecker => TypeChecker.fromRuntime(ClassSwitch);


  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return makeSubtypes(library);
  }

  String makeSubtypes(LibraryReader library) {
    var annotatedElements = library.annotatedWith(subtypeChecker);
    if (annotatedElements.isEmpty) {
      return "";
    }
    List<ClassElement> classElements =
        annotatedElements.map((e) => e.element as ClassElement).toList();

    return classElements
        .map((e) => genSubtype(e.name,
            library.classes.where((s) => s.supertype.element == e).toList()))
        .join();
  }

  String genSubtype(String superType, List<ClassElement> subTypes) {
    final handlerClass = generateSwitcherClass(superType, subTypes);
    final handlerClassWithDefaults =
        generateHandlerClassWithDefaults(superType, subTypes);
    return """
    $handlerClass
    $handlerClassWithDefaults
    """;
  }

  String generateSwitcherFunction(
      String superType, List<ClassElement> subTypes) {
    var arguments = subTypes
        .map((e) => "T Function(${e.name}) ${handler(e.name)}")
        .join(",");

    var first = subTypes[0];
    var rest = subTypes.sublist(1);

    var superTypeParameterName = lowerFirstChar(superType);

    var firstIf =
        ifStatement(superTypeParameterName, first.name, handler(first.name));
    var elseIfs = rest
        .map((e) =>
            elseIfStatement(superTypeParameterName, e.name, handler(e.name)))
        .join();

    return """
    static Function($superType) ${superTypeParameterName}Switcher<T>($arguments) {
      return ($superTypeParameterName) {
    $firstIf
    $elseIfs
    else {
      throw UnimplementedError(
          "Unknown class given to switcher: \$$superTypeParameterName. Subtype code generation has done something incorrectly. ");
    }
      };
    }
    """;
  }

  String handler(String type) => "${lowerFirstChar(type)}";

  String ifStatement(String param, String type, String handler) => """
  if($param is $type) {
    return $handler($param);
  }
  """;

  String elseIfStatement(String param, String type, String handler) => """
  else if($param is $type) {
    return $handler($param);
  }
  """;

  String lowerFirstChar(String e) => e.replaceRange(0, 1, e[0].toLowerCase());

  String generateSwitcherClass(String superType, List<ClassElement> subTypes) {
    final switcherFunction = generateSwitcherFunction(superType, subTypes);
    final superTypeArgument = lowerFirstChar(superType);
    final superTypeHandlerFunction = "${lowerFirstChar(superType)}Switcher";
    final subTypeMethodNames =
        subTypes.map((sub) => lowerFirstChar(sub.name)).join(",");
    final subTypeMethodDefinitions = subTypes.map((sub) {
      var lowerSubType = lowerFirstChar(sub.name);
      return """T $lowerSubType(${sub.name} $lowerSubType);""";
    }).join("\n");
    return """
    abstract class ${superType}Switcher<T> {
      $switcherFunction
      T accept$superType($superType $superTypeArgument) {
        return ${superTypeHandlerFunction}($subTypeMethodNames)($superTypeArgument);
      }
       
      $subTypeMethodDefinitions
    }
    """;
  }

  String generateHandlerClassWithDefaults(
      String superType, List<ClassElement> subTypes) {
    final superTypeArgument = lowerFirstChar(superType);
    final superTypeSwitcherClass = "${lowerFirstChar(superType)}Switcher";
    final subTypeMethodNames =
        subTypes.map((sub) => lowerFirstChar(sub.name)).join(",");
    final subTypeMethodDefinitions = subTypes.map((sub) {
      var lowerSubType = lowerFirstChar(sub.name);
      return """T $lowerSubType(${sub.name} $lowerSubType){
        return defaultValue();
      }""";
    }).join("\n");
    return """
    abstract class ${superType}SwitcherWithDefault<T> {
      T accept$superType($superType $superTypeArgument) {
        return ${superType}Switcher.${superTypeSwitcherClass}($subTypeMethodNames)($superTypeArgument);
      }
      
      T defaultValue();
       
      $subTypeMethodDefinitions
    }
    """;
  }
}
