library python_ffi_macos;

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart" as path_provider;
import "package:python_ffi_macos_dart/python_ffi_macos_dart.dart";
import "package:python_ffi_platform_interface/python_ffi_platform_interface.dart";

// const String _libName = "libpython3.11";
const String _libPath =
    "/Library/Frameworks/Python.framework/Versions/3.11/Python";

abstract class _PythonFfiMacOS extends PythonFfiPlatform<Pointer<PyObject>>
    implements PythonFfiMacOSBase {
  @override
  Future<Directory> getApplicationSupportDirectory() async =>
      path_provider.getApplicationSupportDirectory();

  @override
  FutureOr<ByteData> loadPythonFile(PythonSourceFileEntity sourceFile) {
    if (sourceFile is SourceFile) {
      return PlatformAssetBundle().load("python-modules/${sourceFile.name}");
    } else if (sourceFile is SourceBytes) {
      return ByteData.view(sourceFile.bytes.buffer);
    } else if (sourceFile is SourceBase64) {
      return ByteData.view(base64Decode(sourceFile.base64).buffer);
    }
    throw Exception("Unsupported source file type: $sourceFile");
  }
}

/// The macOS implementation of [PythonFfiPlatform].
class PythonFfiMacOS extends _PythonFfiMacOS with PythonFfiMacOSMixin {
  /// Registers this class as the default instance of [PythonFfiPlatform].
  static void registerWith() {
    PythonFfiPlatform.instance = PythonFfiMacOS();
  }

  @override
  FutureOr<void> prepareModule(PythonModuleDefinition moduleDefinition) {
    final PythonSourceFileEntity? license = moduleDefinition.license;
    if (license != null) {
      LicenseRegistry.addLicense(() async* {
        final ByteData licenseBytes = await loadPythonFile(license);
        final String licenseText =
            utf8.decode(licenseBytes.buffer.asUint8List());
        yield LicenseEntryWithLineBreaks(
          <String>[moduleDefinition.name],
          licenseText,
        );
      });
    }
    return super.prepareModule(moduleDefinition);
  }
}
