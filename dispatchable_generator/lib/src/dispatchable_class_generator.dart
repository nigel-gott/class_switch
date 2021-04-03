import 'package:analyzer/dart/element/element.dart';

import 'code_builders.dart';

class TypeWithSubTypes {
  final ClassElement type;
  final List<ClassElement> subTypes;

  TypeWithSubTypes(this.type, this.subTypes);
}

class BaseNameWithSubNames {
  final String baseName;
  final List<String> subNames;

  BaseNameWithSubNames(this.baseName, this.subNames);
}

class DispatchableClassGenerator {
  final List<BaseNameWithSubNames> _classes;
  final String _targetClassName;
  final List<List<String>> _subTypePermutations;
  final String methodPrefix;
  final String methodSeparator;

  String get _dispatchableClassName => '_\$' + _targetClassName + 'Dispatcher';

  String get _dispatchableStaticFunctionName => 'acceptFunc';

  bool get _generateSubTypeSpecificDefaultMethods => _classes.length > 1;

  DispatchableClassGenerator._withClasses(this._targetClassName, this._classes,
      this._subTypePermutations, this.methodSeparator, this.methodPrefix);

  factory DispatchableClassGenerator.create(
      ClassElement _baseClass,
      List<TypeWithSubTypes> _subClasses,
      String methodPrefix,
      String methodSeparator) {
    var _classes = [
      ..._subClasses.map((TypeWithSubTypes e) {
        return BaseNameWithSubNames(e.type.name, [
          ...e.subTypes.map((e) => e.name).toList(),
          if (!e.type.isAbstract) e.type.name,
        ]);
      }),
    ];
    var algo =
        PermutationAlgorithmStrings(_classes.map((e) => e.subNames).toList());

    return DispatchableClassGenerator._withClasses(_baseClass.name, _classes,
        algo.permutations(), methodPrefix, methodSeparator);
  }

  String generateDispatcherClass() {
    return _generateDispatcherClass(true);
  }

  String generateDefaultDispatcherClass() {
    return _generateDispatcherClass(false);
  }

  String _generateDispatcherClass(bool withDefault) {
    String className =
        _dispatchableClassName + (withDefault ? 'WithDefault' : '');
    ClassBuilder classBuilder = ClassBuilder(className);
    _addAcceptMethod(classBuilder);
    if (withDefault) {
      _addAbstractDefaultMethods(classBuilder);
    } else {
      _addStaticDispatchMethod(classBuilder);
    }
    _addSubClassMethods(withDefault, classBuilder);
    return classBuilder.build();
  }

  void _addSubClassMethods(bool withDefault, ClassBuilder classBuilder) {
    this._subTypePermutations.forEach((subTypePermutation) {
      String methodName = _classMethodName(subTypePermutation);
      List<String> parameterNames = _classMethodParamNames(subTypePermutation);
      MethodBuilder builder = classBuilder.addMethod(methodName)
        ..withParameters(parameterNames)
        ..andReturns('T');
      if (withDefault) {
        var defaultMethodName = _generateSubTypeSpecificDefaultMethods
            ? 'defaultValue${subTypePermutation.first}'
            : 'defaultValue';
        var body = 'return $defaultMethodName();';
        builder.withBody(body);
      } else {
        builder.whichIsAbstract();
      }
    });
  }

  void _addAbstractDefaultMethods(ClassBuilder classBuilder) {
    if (_generateSubTypeSpecificDefaultMethods) {
      _classes.first.subNames.forEach((element) {
        classBuilder.addMethod('defaultValue$element')
          ..withBody('return defaultValue();')
          ..andReturns('T');
      });
    }
    classBuilder.addMethod('defaultValue')
      ..whichIsAbstract()
      ..andReturns('T');
  }

  void _addAcceptMethod(ClassBuilder classBuilder) {
    var baseNameSet =
        this._classes.map((e) => _lowerFirstChar(e.baseName)).toSet();
    var methodNames = this._subTypePermutations.map((subTypePermutation) {
      var classMethodName = _classMethodName(subTypePermutation);
      if (baseNameSet.contains(classMethodName)) {
        return 'this.${classMethodName}';
      } else {
        return classMethodName;
      }
    });
    var instanceArgs = this
        ._classes
        .map((e) => e.baseName)
        .map(this._lowerFirstChar)
        .join(', ');
    var instanceParams = this
        ._classes
        .map((e) => e.baseName)
        .map((e) => '$e ${this._lowerFirstChar(e)}')
        .toList();
    String acceptArgs = methodNames.join(',');
    String body =
        'return $_dispatchableClassName.$_dispatchableStaticFunctionName'
        '($acceptArgs)($instanceArgs);';
    classBuilder.addMethod('accept')
      ..withParameters(instanceParams)
      ..withBody(body)
      ..andReturns('T');
  }

  void _addStaticDispatchMethod(ClassBuilder classBuilder) {
    var parameters = _subTypePermutations.map((subTypePermutation) {
      var funcParams = subTypePermutation.join(', ');
      var name = _classMethodName(subTypePermutation);
      return 'T Function($funcParams) $name';
    });
    var baseClassTypes = _classes.map((e) => e.baseName).join(', ');
    classBuilder.addMethod(_dispatchableStaticFunctionName)
      ..whichIsStatic()
      ..whichHasATemplateParameter('T')
      ..withParameters(parameters)
      ..withBody(_generateDispatcherFunctionBody())
      ..andReturns('T Function($baseClassTypes)');
  }

  String _generateDispatcherFunctionBody() {
    var baseClassParamNames =
        _classes.map((e) => '${_lowerFirstChar(e.baseName)}Param').join(', ');
    var baseClassParamNamesWithDollars =
        _classes.map((e) => '\$${_lowerFirstChar(e.baseName)}Param').join(', ');
    var baseClassTypeNames = _classes.map((e) => e.baseName).join(', ');
    return '''
      return ($baseClassParamNames) {
      ${_generateIfBloc()}
     else {
      throw ArgumentError(
        "Unknown class given to one or all of dispatchable's accept args: $baseClassParamNamesWithDollars. Have you added a new sub class for any of: $baseClassTypeNames without running pub run build_runner build?. "
      );
    }
    };
    ''';
  }

  String _generateIfBloc() {
    final List<String> firstSubClass = _subTypePermutations.first;
    final List<List<String>> remainingSubClassNames =
        _subTypePermutations.sublist(1);
    final List<String> paramNames =
        _classes.map((e) => '${_lowerFirstChar(e.baseName)}Param').toList();

    final String firstIf = _ifStatement(
        paramNames, firstSubClass, _classMethodName(firstSubClass), false);
    final String elseIfs = remainingSubClassNames.map((e) {
      return _ifStatement(paramNames, e, _classMethodName(e), true);
    }).join();
    return '''
    $firstIf
    $elseIfs
    ''';
  }

  String _classMethodName(List<String> types) =>
      _lowerFirstChar(this.methodPrefix + types.join(this.methodSeparator));

  String _ifStatement(
      List<String> params, List<String> types, String handler, bool elseIf) {
    var ises = [];
    for (var i = 0; i < params.length; i++) {
      ises.add('${params[i]} is ${types[i]}');
    }
    return '''
  ${elseIf ? 'else ' : ''}if(${ises.join(' && ')}) {
    return $handler(${params.join(', ')});
  }
  ''';
  }

  String _lowerFirstChar(String e) => e.replaceRange(0, 1, e[0].toLowerCase());

  List<String> _classMethodParamNames(List<String> subNames) {
    return subNames.map((e) => '$e ${_lowerFirstChar(e)}').toList();
  }
}

class PermutationAlgorithmStrings {
  final List<List<String>> elements;

  PermutationAlgorithmStrings(this.elements);

  List<List<String>> permutations() {
    List<List<String>> perms = [];
    generatePermutations(elements, perms, 0, []);
    return perms;
  }

  void generatePermutations(List<List<String>> lists, List<List<String>> result,
      int depth, List<String> current) {
    if (depth == lists.length) {
      result.add(current);
      return;
    }

    for (int i = 0; i < lists[depth].length; i++) {
      generatePermutations(
          lists, result, depth + 1, [...current, lists[depth][i]]);
    }
  }
}
