import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:class_switch/src/class_switch_base.dart';

class ClassSwitchGenerator extends Generator {

  static const TypeChecker ClassSwitchAnnotationTypeChecker = TypeChecker.fromRuntime(ClassSwitch);


  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return makeSubtypes(library);
  }

  String makeSubtypes(LibraryReader library) {
    var codeElementsAnnotatedWithClassSwitch = library.annotatedWith(ClassSwitchAnnotationTypeChecker);
    if (codeElementsAnnotatedWithClassSwitch.isEmpty) {
      return "";
    }
    return codeElementsAnnotatedWithClassSwitch.map((e) => generateCodeForAnnotatedElement(e.element, library)).join();

  }

  String generateCodeForAnnotatedElement(Element e, LibraryReader library) {
    if(e is ClassElement) {
      return generateCodeForAnnotatedClassElement(e, library);
    } else {
      throw Exception("Only class's can be annotated with @class_switch, incorrectly found $e annotated with it!");
    }
  }
  String generateCodeForAnnotatedClassElement(ClassElement e, LibraryReader library) {
    return generateCodeForClassAndSubClasses(e, library.classes.where((s) => s.supertype.element == e).toList());
  }

  String generateCodeForClassAndSubClasses(ClassElement superType, List<ClassElement> subTypes) {
    final String superTypeName = superType.name;
    final subTypeNames = subTypes.map((e) => e.name).toList();
    return """
    ${generateSwitcherClass(superTypeName, subTypeNames)}
    ${generateSwitcherClassWithDefaults(superTypeName, subTypeNames)}
    """;
  }

  String generateSwitcherClass(String superTypeName, List<String> subTypeNames) {
    final String switcherFunction = generateSwitcherFunction(superTypeName, subTypeNames);
    final String subTypeMethodDefinitions = generateAbstractSubTypeMethods(subTypeNames);
    final String switcherAcceptFunction = generateSwitcherAcceptFunction(superTypeName, subTypeNames);
    return """
    abstract class ${superTypeName}Switcher<T> {
      $switcherFunction
      $switcherAcceptFunction 
       
      $subTypeMethodDefinitions
    }
    """;
  }

  String generateSwitcherAcceptFunction(String superTypeName, List<String> subTypeNames){
    final acceptFunctionParameterName = lowerFirstChar(superTypeName);
    final subTypeMethodNamesAsParameterList = subTypeNames.map(subTypeAbstractMethodName).join(",");
    return """
      T accept$superTypeName($superTypeName $acceptFunctionParameterName) {
        return ${switcherFunctionName(superTypeName)}($subTypeMethodNamesAsParameterList)($acceptFunctionParameterName);
      }
    """;
  }

  String generateAbstractSubTypeMethods(List<String> subTypeNames) {
    return subTypeNames.map((subTypeName) {
    final String methodName = subTypeAbstractMethodName(subTypeName);
    final String subTypeParameterName = methodName;
    return """T $methodName(${subTypeName} $subTypeParameterName);""";
  }).join("\n");
  }

  String subTypeAbstractMethodName(String subTypeClassName) => lowerFirstChar(subTypeClassName);

  String switcherFunctionName(String superType) => "${lowerFirstChar(superType)}Switcher";

  String generateSwitcherFunction(
      String superType, List<String> subTypeNames) {
    final String subTypeMethodParameters = subTypeNames
        .map((e) => "T Function($e) ${handler(e)}")
        .join(",");

    final String firstSubType = subTypeNames[0];
    final List<String> remainingSubTypeNames = subTypeNames.sublist(1);

    var superTypeParameterName = lowerFirstChar(superType);

    var firstIf =
        ifStatement(superTypeParameterName, firstSubType, handler(firstSubType));
    var elseIfs = remainingSubTypeNames
        .map((e) =>
            elseIfStatement(superTypeParameterName, e, handler(e)))
        .join();

    return """
    static Function($superType) ${superTypeParameterName}Switcher<T>($subTypeMethodParameters) {
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

  String generateSwitcherClassWithDefaults(
      String superType, List<String> subTypeNames) {
    final String superTypeArgument = lowerFirstChar(superType);
    final String superTypeSwitcherClass = switcherFunctionName(superType);
    final String subTypeMethodNames =
        subTypeNames.map((sub) => subTypeAbstractMethodName(sub)).join(",");
    final String subTypeMethodDefinitions = subTypeNames.map((sub) {
      final String subTypeMethodName = subTypeAbstractMethodName(sub);
      return """T $subTypeMethodName(${sub} $subTypeMethodName){
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
