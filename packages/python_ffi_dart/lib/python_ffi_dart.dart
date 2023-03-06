/// Support for doing something awesome.
///
/// More dartdocs go here.
library python_ffi_dart;

import "dart:async";
import "dart:io";

import "package:python_ffi_interface/python_ffi_interface.dart";
import "package:python_ffi_macos_dart/python_ffi_macos_dart.dart";

export "package:python_ffi_interface/python_ffi_interface.dart";
export "package:python_ffi_macos_dart/python_ffi_macos_dart.dart"
    show GenericExtension;

part "src/class.dart";
part "src/extensions/future.dart";
part "src/function.dart";
part "src/module.dart";
part "src/object.dart";
part "src/python_ffi_dart_base.dart";
