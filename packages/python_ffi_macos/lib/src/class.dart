part of python_ffi_macos;


class PythonClassDefinitionMacos
    extends PythonClassDefinitionPlatform<PythonFfiMacOS, Pointer<PyObject>>
    with _PythonObjectMacosMixin {
  PythonClassDefinitionMacos(super.platform, super.reference);

  @override
  PythonClassMacos newInstance(
    List<Object?> args, [
    Map<String, Object?>? kwargs,
  ]) {
    final List<_PythonObjectMacos> pyArgs =
        args.map((Object? e) => e._toPythonObject(platform)).toList();
    final Map<String, _PythonObjectMacos> pyKwargs =
        Map<String, _PythonObjectMacos>.fromEntries(
      (kwargs?.entries ?? <MapEntry<String, Object?>>[])
          .map(
            (MapEntry<String, Object?> e) =>
                MapEntry<String, _PythonObjectMacos>(
              e.key,
              e.value._toPythonObject(platform),
            ),
          )
          .toList(),
    );

    final Pointer<PyObject> instance = rawCall(
      args: pyArgs.map((_PythonObjectMacos e) => e.reference).toList(),
      kwargs: pyKwargs.map(
        (String key, _PythonObjectMacos value) =>
            MapEntry<String, Pointer<PyObject>>(key, value.reference),
      ),
    );

    for (final _PythonObjectMacos pyArg in pyArgs) {
      pyArg.dispose();
    }
    for (final _PythonObjectMacos pyKwarg in pyKwargs.values) {
      pyKwarg.dispose();
    }

    return PythonClassMacos(platform, instance);
  }

  @override
  T call<T extends Object?>(
    List<Object?> args, {
    Map<String, Object?>? kwargs,
  }) =>
      _PythonObjectMacosMixin.staticCall<T>(
        platform,
        reference,
        args,
        kwargs: kwargs,
      );

  @override
  Pointer<PyObject> rawCall({
    List<Pointer<PyObject>>? args,
    Map<String, Pointer<PyObject>>? kwargs,
  }) =>
      _PythonObjectMacosMixin.staticRawCall(
        platform,
        reference,
        args: args,
        kwargs: kwargs,
      );
}

class PythonClassMacos
    extends PythonClassPlatform<PythonFfiMacOS, Pointer<PyObject>>
    with _PythonObjectMacosMixin {
  PythonClassMacos(super.platform, super.reference);

  final Map<String, PythonFunctionMacos> _functions =
      <String, PythonFunctionMacos>{};

  @override
  PythonFunctionMacos getMethod(String functionName) =>
      getFunction_(functionName, _functions);

  @override
  void dispose() {
    for (final PythonFunctionMacos function in _functions.values) {
      function.dispose();
    }
    _functions.clear();
    super.dispose();
  }

  @override
  String toString() => getMethod("__str__").call<String>(<Object?>[]);
}
