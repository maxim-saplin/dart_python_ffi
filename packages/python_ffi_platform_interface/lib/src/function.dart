part of python_ffi_platform_interface;

abstract class PythonFunctionPlatform<P extends PythonFfiPlatform<R>,
    R extends Object?> extends PythonObjectPlatform<P, R> {
  PythonFunctionPlatform(super.platform, super.reference);

  T call<T extends Object?>(List<Object?> args, {Map<String, Object?>? kwargs});

  R rawCall({List<R>? args, Map<String, R>? kwargs});
}
