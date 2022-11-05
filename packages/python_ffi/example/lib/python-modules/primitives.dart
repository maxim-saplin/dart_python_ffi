import "dart:async";

import "package:python_ffi/python_ffi.dart";

class PrimitivesModule extends PythonModule {
  PrimitivesModule.from(super.pythonModule) : super.from();

  static FutureOr<PrimitivesModule> import() async =>
      PythonFfi.instance.importModule(
        "primitives",
        PrimitivesModule.from,
      );

  int sum(int a, int b) => getFunction("sum").call(<Object?>[a, b]);

  int multiply(int a, int b) => getFunction("multiply").call(<Object?>[a, b]);

  int subtract(int a, int b) => getFunction("subtract").call(<Object?>[a, b]);
}
