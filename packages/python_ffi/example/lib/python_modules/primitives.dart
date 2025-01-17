import "package:python_ffi/python_ffi.dart";

final class PrimitivesModule extends PythonModule {
  PrimitivesModule.from(super.pythonModule) : super.from();

  static PrimitivesModule import() => PythonFfi.instance.importModule(
        "primitives",
        PrimitivesModule.from,
      );

  int sum(int a, int b) => getFunction("sum").call(<Object?>[a, b]);

  int multiply(int a, int b) => getFunction("multiply").call(<Object?>[a, b]);

  int subtract(int a, int b) => getFunction("subtract").call(<Object?>[a, b]);

  int sqrt(int a) => getFunction("sqrt").call(<Object?>[a]);
}
