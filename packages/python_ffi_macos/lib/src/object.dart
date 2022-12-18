import "dart:ffi";

import "package:ffi/ffi.dart";
import "package:flutter/foundation.dart";
import "package:python_ffi_macos/python_ffi_macos.dart";
import "package:python_ffi_macos/src/exception.dart";
import "package:python_ffi_macos/src/extensions/convert_extension.dart";
import "package:python_ffi_macos/src/extensions/malloc_extension.dart";
import "package:python_ffi_macos/src/extensions/object_extension.dart";
import "package:python_ffi_macos/src/ffi/generated_bindings.g.dart";
import "package:python_ffi_macos/src/function.dart";
import "package:python_ffi_platform_interface/python_ffi_platform_interface.dart";

class PythonObjectMacos
    extends PythonObjectPlatform<PythonFfiMacOS, Pointer<PyObject>>
    with PythonObjectMacosMixin {
  PythonObjectMacos(super.platform, super.reference);
}

mixin PythonObjectMacosMixin
    on PythonObjectPlatform<PythonFfiMacOS, Pointer<PyObject>> {
  static T staticCall<T extends Object?>(
    PythonFfiMacOS platform,
    Pointer<PyObject> reference,
    List<Object?> args, {
    Map<String, Object?>? kwargs,
  }) {
    final List<Pointer<PyObject>> mappedArgs = <Pointer<PyObject>>[];
    for (final Object? arg in args) {
      final PythonObjectMacos a = arg.toPythonObject(platform);
      final Pointer<PyObject> b = a.reference;
      mappedArgs.add(b);
    }

    final Map<String, Pointer<PyObject>>? mappedKwargs = kwargs?.map(
      (String key, Object? value) => MapEntry<String, Pointer<PyObject>>(
        key,
        value.toPythonObject(platform).reference,
      ),
    );

    final Pointer<PyObject> rawResult = staticRawCall(
      platform,
      reference,
      args: mappedArgs,
      kwargs: mappedKwargs,
    );

    final PythonObjectMacos result = PythonObjectMacos(platform, rawResult);

    final Object? mappedResult = result.toDartObject();
    if (mappedResult is! PythonObjectPlatform) {
      result.dispose();
    }

    return mappedResult as T;
  }

  /// Calls the python function with raw pyObject args and kwargs
  static Pointer<PyObject> staticRawCall(
    PythonFfiMacOS platform,
    Pointer<PyObject> reference, {
    List<Pointer<PyObject>>? args,
    Map<String, Pointer<PyObject>>? kwargs,
  }) {
    // prepare args
    final int argsLen = args?.length ?? 0;
    final Pointer<PyObject> pArgs = platform.bindings.PyTuple_New(argsLen);
    if (pArgs == nullptr) {
      throw PythonFfiException("Creating argument tuple failed");
    }
    for (int i = 0; i < argsLen; i++) {
      platform.bindings.PyTuple_SetItem(pArgs, i, args![i]);
    }

    // prepare kwargs
    late final Pointer<PyObject> pKwargs;
    final List<PythonObjectMacos> kwargsKeys = <PythonObjectMacos>[];
    if (kwargs == null) {
      pKwargs = nullptr;
    } else {
      pKwargs = platform.bindings.PyDict_New();
      if (pKwargs == nullptr) {
        throw PythonFfiException("Creating keyword argument dict failed");
      }
      for (final MapEntry<String, Pointer<PyObject>> kwarg in kwargs.entries) {
        final PythonObjectMacos kwargKey = kwarg.key.toPythonObject(platform);
        kwargsKeys.add(kwargKey);
        platform.bindings
            .PyDict_SetItem(pKwargs, kwargKey.reference, kwarg.value);
      }
    }

    // call function
    final Pointer<PyObject> result =
        platform.bindings.PyObject_Call(reference, pArgs, pKwargs);

    // deallocate arguments
    platform.bindings.Py_DecRef(pArgs);
    for (final PythonObjectMacos kwargKey in kwargsKeys) {
      kwargKey.dispose();
    }
    if (pKwargs != nullptr) {
      platform.bindings.Py_DecRef(pKwargs);
    }

    // check for errors
    platform.ensureNoPythonError();

    return result;
  }

  @override
  T getAttribute<T extends Object?>(String attributeName) {
    final PythonObjectMacos attribute = getAttributeRaw(attributeName);

    return attribute.reference.toDartObject(platform) as T;
  }

  @override
  T getAttributeRaw<
      T extends PythonObjectPlatform<PythonFfiMacOS, Pointer<PyObject>>>(
    String attributeName,
  ) {
    final Pointer<PyObject> attribute = attributeName.toNativeUtf8().useAndFree(
          (Pointer<Utf8> pointer) => platform.bindings.PyObject_GetAttrString(
            reference,
            pointer.cast<Char>(),
          ),
        );

    if (attribute == nullptr) {
      throw PythonFfiException("Failed to get attribute $attributeName");
    }

    return PythonObjectMacos(platform, attribute) as T;
  }

  @override
  void dispose() {
    platform.bindings.Py_DecRef(reference);
  }

  @override
  Object? toDartObject() => reference.toDartObject(platform);

  PythonFunctionMacos getFunction_(
    String functionName,
    Map<String, PythonFunctionMacos> functions,
  ) {
    final PythonFunctionMacos? cachedFunction = functions[functionName];
    if (cachedFunction != null) {
      platform.bindings.Py_IncRef(cachedFunction.reference);
      return cachedFunction;
    }

    final PythonObjectPlatform<PythonFfiMacOS, Pointer<PyObject>>
        functionAttribute = getAttributeRaw(functionName);
    final PythonFunctionMacos function =
        PythonFunctionMacos(platform, functionAttribute.reference);

    functions[functionName] = function;

    return function;
  }

  void debugDump() {
    debugPrint("========================================");
    debugPrint("PythonObjectMacos: @0x${reference.hexAddress}");
    try {
      try {
        debugPrint("converted: ${reference.toDartObject(platform)}");
      } on PythonFfiException catch (e) {
        debugPrint("converted: @0x${reference.hexAddress} w/ error: $e");
      }

      final PythonObjectPlatform<PythonFfiMacOS, Pointer<PyObject>> dict =
          getAttributeRaw("__dict__");
      debugPrint("dict: @0x${dict.reference.hexAddress}");
      platform.ensureNoPythonError();

      final Pointer<PyObject> keys =
          platform.bindings.PyDict_Keys(dict.reference);
      platform.bindings.Py_IncRef(keys);
      debugPrint("dict-keys: @0x${keys.hexAddress}");
      platform.ensureNoPythonError();

      if (keys == nullptr) {
        debugPrint("dict-keys is null");
      } else {
        final int len = platform.bindings.PyList_Size(keys);
        debugPrint("dict-keys-len: $len");
        platform.ensureNoPythonError();

        for (int i = 0; i < len; i++) {
          final Pointer<PyObject> key =
              platform.bindings.PyList_GetItem(keys, i);
          platform.bindings.Py_IncRef(key);

          final Pointer<PyObject> value =
              platform.bindings.PyDict_GetItem(dict.reference, key);
          platform.bindings.Py_IncRef(value);

          final String keyString = key.toDartObject(platform)! as String;
          Object? valueObject;
          try {
            valueObject = value.toDartObject(platform);
          } on PythonFfiException catch (e) {
            valueObject = "@0x${value.hexAddress} w/ error: $e";
          }
          debugPrint("$keyString: $valueObject");
        }
      }
    } on PythonExceptionMacos catch (e) {
      debugPrint("Error: $e");
    } finally {
      debugPrint("========================================");
    }
  }
}