import 'package:analyzer/dart/element/element.dart';
import 'package:class_switch/class_switch.dart';
import 'package:class_switch_generator/src/code_builders.dart';

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

class ClassSwitchClassGenerator {
  final List<BaseNameWithSubNames> _classes;
  final String _targetClassName;
  final List<List<String>> _subTypePermutations;
  final ClassSwitchOptions options;

  String get _switchClassNamePostfix => 'Switcher';

  String get _switcherClassName =>
      '_\$$_targetClassName$_switchClassNamePostfix';

  String get _switchFunctionPrefix => options.switchFunctionPrefix;

  String get _switchFunctionName =>
      _switchFunctionPrefix + _classes.map((e) => e.baseName).join();

  bool get _generateSubTypeSpecificDefaultMethods => _classes.length > 1;

  String get _extensionMethodNamespace =>
      '_\$${_targetClassName}SwitchExtension';

  String get _extensionMethodName => _switchFunctionPrefix;

  String get _wrapperClassName =>
      '_\$${_classes.map((e) => e.baseName).join()}SwitchWrapper';

  ClassSwitchClassGenerator._withClasses(
    this._targetClassName,
    this._classes,
    this._subTypePermutations,
    this.options,
  );

  factory ClassSwitchClassGenerator.create(
    ClassElement baseClass,
    List<TypeWithSubTypes> subClasses,
    ClassSwitchOptions options,
  ) {
    final classes = [
      ...subClasses.map((TypeWithSubTypes e) {
        return BaseNameWithSubNames(e.type.name, [
          ...e.subTypes.map((e) => e.name),
          if (!e.type.isAbstract) e.type.name,
        ]);
      }),
    ];
    final algo =
        PermutationAlgorithmStrings(classes.map((e) => e.subNames).toList());

    return ClassSwitchClassGenerator._withClasses(
      baseClass.name,
      classes,
      algo.permutations(),
      options,
    );
  }

  String generateAll() {
    final r = [
      if (options.dslMode == DSL_MODE.WRAPPER_CLASS) generateWrapperClass(),
      generateSwitchFunction(),
      generateExtensionMethod(),
      generateDispatcherClass(),
      generateDefaultDispatcherClass(),
    ].join("\n\n");
    // var f = File('$_targetClassName.gen.dart');
    // var s = f.openWrite();
    // s.write(r);
    // s.close();

    return r;
  }

  String generateExtensionMethod() {
    final parameters = caseParameters();
    final parametersNames = _subTypePermutations.map((subTypePermutation) {
      return _classMethodName(subTypePermutation);
    }).join(', ');
    if (_classes.length == 1 && _targetClassName == _classes.first.baseName) {
      final ExtensionBuilder extensionBuilder =
          ExtensionBuilder(_targetClassName, _extensionMethodNamespace);

      final MethodBuilder extensionMethodBuilder =
          (extensionBuilder.addMethod(_extensionMethodName))
            ..whichHasATemplateParameter('T')
            ..withParameters(parameters)
            ..andReturns('T');
      switch (options.dslMode) {
        case DSL_MODE.WRAPPER_CLASS:
          extensionMethodBuilder.withBody(
            'return $_wrapperClassName<T>(this)($parametersNames);',
          );
          break;
        case DSL_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES:
          extensionMethodBuilder.withBody(
            'return $_switchFunctionName<T>(this, $parametersNames);',
          );
          break;
        case DSL_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION:
          extensionMethodBuilder.withBody('return $_switchFunctionName'
              '<T>(this)($parametersNames);');
          break;
      }
      return extensionBuilder.build();
    } else {
      final instanceParams = _classes
          .map((e) => '${e.baseName} ${_lowerFirstChar(e.baseName)}Param');
      final instanceParamNames =
          _classes.map((e) => '${_lowerFirstChar(e.baseName)}Param').join(',');

      final parameters = caseParameters();
      final parameterNames = _subTypePermutations.map((subTypePermutation) {
        return _classMethodName(subTypePermutation);
      }).join(', ');

      final extensionBuilder =
          ExtensionBuilder(_targetClassName, _extensionMethodNamespace);
      final methodBuilder = extensionBuilder.addMethod(_extensionMethodName)
        ..whichHasATemplateParameter('T');
      switch (options.dslMode) {
        case DSL_MODE.WRAPPER_CLASS:
          methodBuilder
            ..withParameters(instanceParams)
            ..withBody('''return $_wrapperClassName<T>($instanceParamNames);''')
            ..andReturns('$_wrapperClassName<T>');
          break;
        case DSL_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES:
          methodBuilder
            ..withParameters(instanceParams)
            ..withParameters(parameters)
            ..withBody(
              '''return $_switchFunctionName<T>($instanceParamNames, $parameterNames);''',
            )
            ..andReturns('T');
          break;
        case DSL_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION:
          methodBuilder
            ..withParameters(instanceParams)
            ..withBody(
              '''return $_switchFunctionName<T>($instanceParamNames);''',
            )
            ..andReturns('T Function(${parameters.join(',')})');
          break;
      }
      return extensionBuilder.build();
    }
  }

  Iterable<String> caseParameters() {
    return _subTypePermutations.map((subTypePermutation) {
      final funcParams =
          subTypePermutation.map((e) => '$e ${_lowerFirstChar(e)}').join(', ');
      final name = _classMethodName(subTypePermutation);
      return 'T Function($funcParams) $name';
    });
  }

  String generateSwitchFunction() {
    switch (options.dslMode) {
      case DSL_MODE.WRAPPER_CLASS:
        final params = _classes
            .map((e) => '${e.baseName} ${_lowerFirstChar(e.baseName)}Param');
        return (MethodBuilder(_switchFunctionName)
              ..whichHasATemplateParameter('T')
              ..withParameters(params)
              ..withBody(_generateSwitchFunctionBody())
              ..andReturns('$_wrapperClassName<T>'))
            .build();
      case DSL_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES:
        final parameters = (_classes.map(
          (e) => '${e.baseName} ${_lowerFirstChar(e.baseName)}Param',
        )).toList();
        parameters.addAll(caseParameters().toList());
        return (MethodBuilder(_switchFunctionName)
              ..whichHasATemplateParameter('T')
              ..withParameters(parameters)
              ..withBody(_generateSwitchFunctionBody())
              ..andReturns('T'))
            .build();
      case DSL_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION:
        final parameters = caseParameters().join(', ');
        final params = _classes
            .map((e) => '${e.baseName} ${_lowerFirstChar(e.baseName)}Param');
        return (MethodBuilder(_switchFunctionName)
              ..whichHasATemplateParameter('T')
              ..withParameters(params)
              ..withBody(_generateSwitchFunctionBody())
              ..andReturns('T Function($parameters)'))
            .build();
    }
  }

  String generateDispatcherClass() {
    return _generateDispatcherClass(true);
  }

  String generateDefaultDispatcherClass() {
    return _generateDispatcherClass(false);
  }

  String _generateDispatcherClass(bool withDefault) {
    final String className =
        _switcherClassName + (withDefault ? 'WithDefault' : '');
    final ClassBuilder classBuilder = ClassBuilder(className);
    classBuilder
      ..whichIsAbstract()
      ..whichHasATemplateParameter('T');
    _addAcceptMethod(classBuilder);
    if (withDefault) {
      _addAbstractDefaultMethods(classBuilder);
    }
    _addSubClassMethods(withDefault, classBuilder);
    return classBuilder.build();
  }

  void _addSubClassMethods(bool withDefault, ClassBuilder classBuilder) {
    for (final subTypePermutation in _subTypePermutations) {
      final String methodName = _classMethodName(subTypePermutation);
      final List<String> parameterNames =
          _classMethodParamNames(subTypePermutation);
      final MethodBuilder builder = classBuilder.addMethod(methodName)
        ..withParameters(parameterNames)
        ..andReturns('T');
      if (withDefault) {
        final defaultMethodName = _generateSubTypeSpecificDefaultMethods
            ? 'defaultValue${subTypePermutation.first}'
            : 'defaultValue';
        final body = 'return $defaultMethodName();';
        builder.withBody(body);
      } else {
        builder.whichIsAbstract();
      }
    }
  }

  void _addAbstractDefaultMethods(ClassBuilder classBuilder) {
    if (_generateSubTypeSpecificDefaultMethods) {
      for (final element in _classes.first.subNames) {
        classBuilder.addMethod('defaultValue$element')
          ..withBody('return defaultValue();')
          ..andReturns('T');
      }
    }
    classBuilder.addMethod('defaultValue')
      ..whichIsAbstract()
      ..andReturns('T');
  }

  void _addAcceptMethod(ClassBuilder classBuilder) {
    final baseNameSet =
        _classes.map((e) => _lowerFirstChar(e.baseName)).toSet();
    final methodNames = _subTypePermutations.map((subTypePermutation) {
      final classMethodName = _classMethodName(subTypePermutation);
      if (baseNameSet.contains(classMethodName)) {
        return 'this.$classMethodName';
      } else {
        return classMethodName;
      }
    });
    final instanceArgs =
        _classes.map((e) => e.baseName).map(_lowerFirstChar).join(', ');
    final instanceParams = _classes
        .map((e) => e.baseName)
        .map((e) => '$e ${_lowerFirstChar(e)}')
        .toList();
    final String methodArgs = methodNames.join(',');
    var body = '';
    switch (options.dslMode) {
      case DSL_MODE.WRAPPER_CLASS:
        body = 'return $_wrapperClassName<T>($instanceArgs)($methodArgs);';
        break;
      case DSL_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES:
        body = 'return $_switchFunctionName<T>($instanceArgs, $methodArgs);';
        break;
      case DSL_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION:
        body = 'return $_switchFunctionName<T>($instanceArgs)($methodArgs);';
        break;
    }
    classBuilder.addMethod(_switchFunctionPrefix)
      ..withParameters(instanceParams)
      ..withBody(body)
      ..andReturns('T');
  }

  String _generateSwitchFunctionBody() {
    switch (options.dslMode) {
      case DSL_MODE.WRAPPER_CLASS:
        final params = _classes
            .map((e) => '${_lowerFirstChar(e.baseName)}Param')
            .join(', ');
        return 'return $_wrapperClassName<T>($params);';
      case DSL_MODE.SINGLE_METHOD_WITH_INSTANCES_AND_CASES:
        final baseClassParamNamesWithDollars = _classes
            .map((e) => '\$${_lowerFirstChar(e.baseName)}Param')
            .join(', ');
        final baseClassTypeNames = _classes.map((e) => e.baseName).join(', ');
        return '''
      ${_generateIfBloc()}
     else {
      throw ArgumentError(
        'Unknown class given to \\$_switchFunctionPrefix: $baseClassParamNamesWithDollars. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for any of: $baseClassTypeNames without running pub run build_runner build?. '
      );
    }
    ''';
      case DSL_MODE.OUTER_METHOD_TAKES_INSTANCES_AND_RETURNS_CASE_FUNCTION:
        final baseClassParamNames = _subTypePermutations
            .map((e) => 'T Function(${e.join(', ')}) ${_classMethodName(e)}')
            .join(', ');
        final baseClassParamNamesWithDollars = _classes
            .map((e) => '\$${_lowerFirstChar(e.baseName)}Param')
            .join(', ');
        final baseClassTypeNames = _classes.map((e) => e.baseName).join(', ');
        return '''
      return ($baseClassParamNames) {
      ${_generateIfBloc()}
     else {
      throw ArgumentError(
        'Unknown class given to \\$_switchFunctionPrefix: $baseClassParamNamesWithDollars. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for any of: $baseClassTypeNames without running pub run build_runner build?. '
      );
    }
    };
    ''';
    }
  }

  String _generateIfBloc() {
    final List<String> firstSubClass = _subTypePermutations.first;
    final List<List<String>> remainingSubClassNames =
        _subTypePermutations.sublist(1);
    final List<String> paramNames =
        _classes.map((e) => '${_lowerFirstChar(e.baseName)}Param').toList();

    final String firstIf = _ifStatement(
      paramNames,
      firstSubClass,
      _classMethodName(firstSubClass),
      false,
    );
    final String elseIfs = remainingSubClassNames.map((e) {
      return _ifStatement(paramNames, e, _classMethodName(e), true);
    }).join();
    return '''
    $firstIf
    $elseIfs
    ''';
  }

  String _classMethodName(List<String> types) => _lowerFirstChar(
        options.abstractMethodPrefix +
            types.join(options.abstractMethodSubTypeSeparator),
      );

  String _ifStatement(
    List<String> params,
    List<String> types,
    String handler,
    bool elseIf,
  ) {
    final ises = [];
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

  String generateWrapperClass() {
    final classBuilder = ClassBuilder(_wrapperClassName)
      ..whichHasATemplateParameter('T')
      ..addConstructorWithFinalAttributes(
        _classes
            .map(
              (e) =>
                  TypeAndName(e.baseName, '${_lowerFirstChar(e.baseName)}Attr'),
            )
            .toList(),
      );

    final baseClassParamNames = caseParameters();

    final wrapperClassAttributesWithDollars =
        _classes.map((e) => '\$${_lowerFirstChar(e.baseName)}Attr').join(', ');
    final wrapperClassAttributeAssignments = _classes
        .map(
          (e) =>
              'var ${_lowerFirstChar(e.baseName)}Param = ${_lowerFirstChar(e.baseName)}Attr;',
        )
        .join('\n');
    final baseClassTypeNames = _classes.map((e) => e.baseName).join(', ');
    classBuilder.addMethod('call')
      ..withParameters(baseClassParamNames)
      ..withBody('''
    $wrapperClassAttributeAssignments
          ${_generateIfBloc()}
    else {
    throw ArgumentError(
    'Unknown class given to \\$_switchFunctionPrefix: $wrapperClassAttributesWithDollars. All sub classes must be in the same or imported into the file with the annotated class, or have you added a new sub class for any of: $baseClassTypeNames without running pub run build_runner build?. '
    );
    }
    ''')
      ..andReturns('T');

    classBuilder.addMethod('cases')
      ..withParameters(baseClassParamNames)
      ..withBody('''
      return call(${_subTypePermutations.map((e) => _classMethodName(e)).join(', ')});
    ''')
      ..andReturns('T');

    return classBuilder.build();
  }
}

class PermutationAlgorithmStrings {
  final List<List<String>> elements;

  PermutationAlgorithmStrings(this.elements);

  List<List<String>> permutations() {
    final List<List<String>> perms = [];
    generatePermutations(elements, perms, 0, []);
    return perms;
  }

  void generatePermutations(
    List<List<String>> lists,
    List<List<String>> result,
    int depth,
    List<String> current,
  ) {
    if (depth == lists.length) {
      result.add(current);
      return;
    }

    for (int i = 0; i < lists[depth].length; i++) {
      generatePermutations(
        lists,
        result,
        depth + 1,
        [...current, lists[depth][i]],
      );
    }
  }
}
