library flutter_package_export;

import "package:flutter_package_export/src/python_modules/basic_adder.dart";
import "package:python_ffi/python_ffi.dart";

final class BuiltinPythonModule extends PythonModule {
  BuiltinPythonModule.from(super.pythonModule) : super.from();

  static BuiltinPythonModule import() =>
      PythonFfi.instance.importModule("builtins", BuiltinPythonModule.from);

  Object? dir(Object? object) => getFunction("dir").call(<Object?>[object]);
}

Future<void> initialize() async =>
    await PythonFfi.instance.initialize(package: "flutter_package_export");

num add(num x, num y) => BasicAdderModule.import().add(x, y);
