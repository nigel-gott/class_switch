import 'package:dispatchable/dispatchable.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
    '@Dispatchable does not support abstract classes with no sub '
    'classes.',
    todo: 'Remove @Dispatchable from BaseClass or define sub classes for it.')
@Dispatchable()
abstract class BaseClass {}

@ShouldThrow(
  '@Dispatchable only supports classes.',
  todo: 'Remove @Dispatchable from cannotAnnotateShortFormFunctions.',
)
@Dispatchable()
int cannotAnnotateShortFormFunctions() => 0;

@ShouldThrow(
  '@Dispatchable only supports classes.',
  todo: 'Remove @Dispatchable from cannotAnnotateEnums.',
)
@Dispatchable()
enum cannotAnnotateEnums { ONE }

@ShouldThrow(
  '@Dispatchable only supports classes.',
  todo: 'Remove @Dispatchable from cannotAnnotateFunctions.',
)
@Dispatchable()
int cannotAnnotateFunctions() {
  return 0;
}

@ShouldThrow(
  '@Dispatchable only supports classes.',
  todo: 'Remove @Dispatchable from cannotAnnotateVariables.',
)
@Dispatchable()
int cannotAnnotateVariables = 0;

class CannotAnnotateInsideAClass {
  @ShouldThrow(
    '@Dispatchable only supports classes.',
    todo:
        'Remove @Dispatchable from cannotAnnotateInsideAnElementInsideAClass.',
  )
  @Dispatchable()
  int cannotAnnotateInsideAnElementInsideAClass = 0;
}
