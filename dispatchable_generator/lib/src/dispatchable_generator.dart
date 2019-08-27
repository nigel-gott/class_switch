import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:optional/optional.dart';
import 'package:source_gen/source_gen.dart';

class DispatchableGenerator extends Generator {
  static const TypeChecker DispatchableAnnotationTypeChecker =
      TypeChecker.fromRuntime(Dispatchable);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final List<AnnotatedElement> codeElementsAnnotatedWithDispatchable =
        library.annotatedWith(DispatchableAnnotationTypeChecker).toList();
    return codeElementsAnnotatedWithDispatchable
        .map((e) => generateForElement(e.element, library))
        .join();
  }

  String generateForElement(Element e, LibraryReader library) {
    DispatchableCodeBuilder dispatchableCodeBuilder = DispatchableCodeBuilder.fromAnnotation(e, library);
    return [
      dispatchableCodeBuilder.generateDispatcherClass(),
      dispatchableCodeBuilder.generateDefaultDispatcherClass(),
    ].join("\n");
  }
}

class DispatchableCodeBuilder {
  final ClassElement _baseClass;
  final List<ClassElement> _subClasses;

  String get _baseClassName => _baseClass.name;

  List<String> get _subClassNames =>
      _subClasses.map((ClassElement e) => e.name).toList();

  factory DispatchableCodeBuilder.fromAnnotation(
      Element element, LibraryReader libraryReader) {
    if (element is ClassElement && !element.isEnum) {
      final List<ClassElement> subClasses = findAllSubClassesInFile(libraryReader, element);
      return DispatchableCodeBuilder._withClassElements(
          element, subClasses);
    } else {
      throw InvalidGenerationSourceError(
          "@dispatchable can only be used to annotate a class.",
          todo: "Remove @dispatchable annotation from the offending element.",
          element: element);
    }
  }

  static List<ClassElement> findAllSubClassesInFile(LibraryReader libraryReader, ClassElement element) {
    return libraryReader.classes
        .where((s) => s.supertype.element == element)
        .toList();
  }

  DispatchableCodeBuilder._withClassElements(
      this._baseClass, this._subClasses);

  get _dispatchableClassName => _baseClassName + "Dispatcher";

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
      if(withDefault){
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
    classBuilder.addMethod("accept$_baseClassName")
      ..withParameter("$_baseClassName $acceptFunctionParameterName")
      ..withBody("return $_dispatchableClassName.${_dispatchableFunctionName()}($_methodParameters)($acceptFunctionParameterName);")

      ..andReturns("T");
  }

  void _addStaticDispatchMethod(ClassBuilder classBuilder) {
    classBuilder.addMethod(_dispatchableFunctionName())
      ..whichIsStatic()
      ..whichHasATemplateParameter("T")
      ..withParameters(_classesAcceptedByDispatcher
          .map((e) => "T Function($e) ${_classMethodName(e)}"))
      ..withBody(_generateDispatcherFunctionBody())
      ..andReturns("T Function($_baseClassName)");
  }



  String get _methodParameters =>
      _classesAcceptedByDispatcher.map(_classMethodName).join(",");


  List<String> get _classesAcceptedByDispatcher =>
      [..._subClassNames, if (!_baseClass.isAbstract) _baseClassName];

  String _dispatchableFunctionName() =>
      "${_lowerFirstChar(_baseClassName)}Dispatcher";

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

}

class ClassBuilder {
  final String _className;
  final List<MethodBuilder> _methods = [];

  ClassBuilder(this._className);

  String build() {
    return """
    abstract class $_className<T> {
    ${_methods.map((f) => f.build()).join("\n")}
    }
    """;
  }

  MethodBuilder addMethod(String methodName) {
    MethodBuilder builder = MethodBuilder(methodName);
    _methods.add(builder);
    return builder;
  }
}

class MethodBuilder {
  final String _methodName;
  final List<String> _parameters = [];
  bool _static = false;
  Optional<String> _templateArgumentName = Optional.empty();
  bool _abstract = false;
  String _returnType = "void";
  String _body = "";

  MethodBuilder(this._methodName);

  String build() {
    String typeParameter = _templateArgumentName.map((t) => "<$t>").orElse("");
    String methodWithoutBody =
        "${_static ? "static" : ""} $_returnType $_methodName${typeParameter}(${_parameters.join(",")})";
    if (_abstract) {
      return methodWithoutBody + ";";
    } else {
      return """$methodWithoutBody {
$_body
}""";
    }
  }

  void whichIsAbstract() {
    _abstract = true;
  }

  void andReturns(String returnType) {
    _returnType = returnType;
  }

  void whichHasATemplateParameter(String _templateArgument) {
    _templateArgumentName = Optional.of(_templateArgument);
  }

  void withParameters(Iterable<String> parameters) {
    _parameters.addAll(parameters);
  }

  void withBody(String body) {
    _body = body;
  }

  void whichIsStatic() {
    _static = true;
  }

  void withParameter(String parameter) {
    _parameters.add(parameter);
  }

  void whichIsAbstractIf(bool abstract) {
    _abstract = abstract;
  }
}
