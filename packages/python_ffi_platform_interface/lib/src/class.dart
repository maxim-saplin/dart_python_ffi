import "package:python_ffi_platform_interface/src/function.dart";
import "package:python_ffi_platform_interface/src/object.dart";
import "package:python_ffi_platform_interface/src/python_ffi_platform.dart";

abstract class PythonClassDefinitionPlatform<P extends PythonFfiPlatform<R>,
    R extends Object?> extends PythonObjectPlatform<P, R> {
  PythonClassDefinitionPlatform(super.platform, super.reference);

  PythonClassPlatform<P, R> newInstance(
    List<Object?> args, [
    Map<String, Object?>? kwargs,
  ]);

  T call<T extends Object?>(List<Object?> args, {Map<String, Object?>? kwargs});

  R rawCall({List<R>? args, Map<String, R>? kwargs});
}

abstract class PythonClassPlatform<P extends PythonFfiPlatform<R>,
    R extends Object?> extends PythonObjectPlatform<P, R> {
  PythonClassPlatform(super.platform, super.reference);

  PythonFunctionPlatform<P, R> getMethod(String functionName);
}
