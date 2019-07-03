import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:type_handler/src/type_handler_base.dart';

class TypeHandlerGenerator extends Generator {
  bool first = true;

  TypeChecker get typeChecker => TypeChecker.fromRuntime(Subtype);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    var annotatedElements = library.annotatedWith(typeChecker);
    if (annotatedElements.isEmpty) {
      return "";
    }
    List<ClassElement> classElements =
        annotatedElements.map((e) => e.element as ClassElement).toList();

    return classElements
        .map((e) => gen(e.name,
            library.classes.where((s) => s.supertype.element == e).toList()))
        .join();
  }

  String gen(String superType, List<ClassElement> subTypes) {
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
    Function($superType) ${superTypeParameterName}Handler<T>($arguments) {
      return ($superTypeParameterName) {
    $firstIf
    $elseIfs
    else {
      throw UnimplementedError(
          "Unknown class given to handler: \$$superTypeParameterName. You must annotate every subtype of $superType with @Subtype. ");
    }
      };
    }
    """;
  }

  String handler(String type) => "${lowerFirstChar(type)}Handler";

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
}
