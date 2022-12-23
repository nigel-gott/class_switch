import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

import 'fruit.dart';
// ignore: unused_import
import 'other_multi_functions.dart';

class Apple extends Fruit {}

class Pear extends Fruit {}

class Orange extends Fruit {}

@M
extension $PrepareFruit on $PrepareFruitMulti {
  List<String> prepareFruit(Fruit f) {
    return ["wash", "chop", "eat"];
  }

  // ignore: non_constant_identifier_names
  List<String> prepareFruit_Orange(Orange f) {
    return ["wash", "peel", "chop", "eat"];
  }
}

List<String> $prepareFruit(Fruit fruit) {
  final f = $PrepareFruitMulti();
  if (fruit is Orange) {
    return f.prepareFruit_Orange(fruit);
  } else if (fruit is Orange2) {
    return f.prepareFruit_Orange2(fruit);
  } else {
    return f.prepareFruit(fruit);
  }
}

void main() {
  group('Tests showing core class_switch multi dispatch library usage.', () {
    group(
        'Annotating methods with @M will generate a multi dispatchable function:',
        () {
      test('Simple', () {
        expect($prepareFruit(Apple()), ['wash', 'chop', 'eat']);
        expect($prepareFruit(Pear()), ['wash', 'chop', 'eat']);
        expect($prepareFruit(Orange()), ['wash', 'peel', 'chop', 'eat']);
      });
    });
  });
}
