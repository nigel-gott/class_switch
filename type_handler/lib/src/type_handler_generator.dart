import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:type_handler/src/type_handler_base.dart';

class TypeHandlerGenerator extends Generator {
  bool first = true;

  TypeChecker get subtypeChecker => TypeChecker.fromRuntime(Subtype);

  TypeChecker get crosstypeChecker => TypeChecker.fromRuntime(CrossSubtype);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return [makeSubtypes(library), makeCrosstypes(library)].join("\n");
  }

  String makeCrosstypes(LibraryReader library) {
    var annotatedElements = library.annotatedWith(crosstypeChecker);
    if (annotatedElements.isEmpty) {
      return "";
    }
    List<ClassElement> classElements =
        annotatedElements.map((e) => e.element as ClassElement).toList();
    if (classElements.length != 2) {
      throw Exception("Crosstype only works for two classes in one file");
    }
    var firstSubtype = classElements[0];
    var firstSubtypes = library.classes
        .where((s) => s.supertype.element == firstSubtype)
        .toList();
    var secondSubtype = classElements[1];
    var secondSubtypes = library.classes
        .where((s) => s.supertype.element == secondSubtype)
        .toList();
    return genCrosstype(
        firstSubtype, firstSubtypes, secondSubtype, secondSubtypes);
  }

  String genCrosstype(ClassElement firstSuper, List<ClassElement> firstSubtypes,
      ClassElement secondSuper, List<ClassElement> secondSubtypes) {
    var allSubtypes = <ClassElement>[firstSuper, secondSuper];
    var superTypeNames = allSubtypes.map((k) => k.name);
    var name = superTypeNames.join("And");
    final className = "${name}Handler";
    final args =
        superTypeNames.map((name) => "$name ${lowerFirstChar(name)}").join(",");

    List<String> funcs = [];

    var entryHandleFunc = "";
    for (var i = 0; i < firstSubtypes.length; i++) {
      var firstSubtype = firstSubtypes[i];
      var firstSuperArg = lowerFirstChar(firstSuper.name);
      if (i == 0) {
        entryHandleFunc += """
        if(${firstSuperArg} is ${firstSubtype.name}){
        """;
      } else if (i == firstSubtypes.length - 1) {
        entryHandleFunc += """
        else {
      """;
      } else {
        entryHandleFunc += """
        else if(${firstSuperArg} is ${firstSubtype.name}){
        """;
      }
      for (var k = 0; k < secondSubtypes.length; k++) {
        var secondSubtype = secondSubtypes[k];
        var handleFuncName =
            "handle${firstSubtype.name}And${secondSubtype.name}";
        var secondSuperArg = lowerFirstChar(secondSuper.name);
        funcs.add(
            "T $handleFuncName(${firstSubtype.name} $firstSuperArg, ${secondSubtype.name} $secondSuperArg);");
        if (k == 0) {
          entryHandleFunc += """
          if(${secondSuperArg} is ${secondSubtype.name}){
            return $handleFuncName($firstSuperArg, $secondSuperArg);
          }""";
        } else if (k == secondSubtypes.length - 1) {
          entryHandleFunc += """
        else {
            return $handleFuncName($firstSuperArg, $secondSuperArg);
            }
      """;
        } else {
          entryHandleFunc += """
          else if(${secondSuperArg} is ${secondSubtype.name}){
            return $handleFuncName($firstSuperArg, $secondSuperArg);
           }
        """;
        }
      }
      entryHandleFunc += """
      }
      """;
    }

    return """
    abstract class $className<T>{
      T handle$name($args){
      $entryHandleFunc
      }
      
      
      ${funcs.join("\n")}
      
    }
    """;
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
    final handlerClass = generateHandlerClass(superType, subTypes);
    final handlerClassWithDefaults =
        generateHandlerClassWithDefaults(superType, subTypes);
    return """
    $handlerClass
    $handlerClassWithDefaults
    """;
  }

  String generateHandlerFunction(
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
    static Function($superType) ${superTypeParameterName}Handler<T>($arguments) {
      return ($superTypeParameterName) {
    $firstIf
    $elseIfs
    else {
      throw UnimplementedError(
          "Unknown class given to handler: \$$superTypeParameterName. Subtype code generation has done something incorrectly. ");
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

  String generateHandlerClass(String superType, List<ClassElement> subTypes) {
    final handlerFunction = generateHandlerFunction(superType, subTypes);
    final superTypeArgument = lowerFirstChar(superType);
    final superTypeHandlerFunction = "${lowerFirstChar(superType)}Handler";
    final subTypeMethodNames =
        subTypes.map((sub) => lowerFirstChar(sub.name)).join(",");
    final subTypeMethodDefinitions = subTypes.map((sub) {
      var lowerSubType = lowerFirstChar(sub.name);
      return """T $lowerSubType(${sub.name} $lowerSubType);""";
    }).join("\n");
    return """
    abstract class ${superType}Handler<T> {
      $handlerFunction
      T handle$superType($superType $superTypeArgument) {
        return ${superTypeHandlerFunction}($subTypeMethodNames)($superTypeArgument);
      }
       
      $subTypeMethodDefinitions
    }
    """;
  }

  String generateHandlerClassWithDefaults(
      String superType, List<ClassElement> subTypes) {
    final superTypeArgument = lowerFirstChar(superType);
    final superTypeHandlerFunction = "${lowerFirstChar(superType)}Handler";
    final subTypeMethodNames =
        subTypes.map((sub) => lowerFirstChar(sub.name)).join(",");
    final subTypeMethodDefinitions = subTypes.map((sub) {
      var lowerSubType = lowerFirstChar(sub.name);
      return """T $lowerSubType(${sub.name} $lowerSubType){
        return defaultValue();
      }""";
    }).join("\n");
    return """
    abstract class ${superType}HandlerWithDefault<T> {
      T handle$superType($superType $superTypeArgument) {
        return ${superType}Handler.${superTypeHandlerFunction}($subTypeMethodNames)($superTypeArgument);
      }
      
      T defaultValue();
       
      $subTypeMethodDefinitions
    }
    """;
  }
}
