// ignore_for_file: non_constant_identifier_names

import "package:python_ffi/python_ffi.dart";

class HelloWorldModule extends PythonModule {
  HelloWorldModule.from(super.pythonModule) : super.from();

  static HelloWorldModule import() => PythonModule.import(
        "hello_world",
        HelloWorldModule.from,
      );

  void hello_world() => getFunction("hello_world").call(<Object?>[]);

  static PythonModuleDefinition get definition => PythonModuleDefinition(
        name: "hello_world",
        root: SourceFile("hello_world.py"),
      );
}