import "package:python_ffi/python_ffi.dart";

class HelloWorldModule extends PythonModule {
  HelloWorldModule.from(super.pythonModule) : super.from();

  static HelloWorldModule import() => PythonModule.import(
        "hello_world",
        HelloWorldModule.from,
      );

  void hello_world() => getFunction("hello_world").call(<Object?>[]);
}
