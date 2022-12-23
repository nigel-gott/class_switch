import 'package:class_switch/class_switch.dart';

import 'fruit.dart';

class Orange2 extends Fruit {}

@M
extension $PrepareFruit on $PrepareFruitMulti {
  List<String> prepareFruit_Orange2(Orange2 f) {
    return ["wash", "peel", "chop", "eat"];
  }
}
