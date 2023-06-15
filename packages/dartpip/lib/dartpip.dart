library dartpip;

import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:args/args.dart";
import "package:args/command_runner.dart";
import "package:collection/collection.dart";
import "package:dartpip/pypi/api.dart";
import "package:http/http.dart" as http;
import "package:yaml/yaml.dart";

part "builtin_modules/python_ffi.py.dart";
part "commands/bundle.dart";
part "commands/bundle_module.dart";
part "constants.dart";
part "extensions.dart";
part "module_bundle/module_bundle.dart";
part "module_bundle/src/console_module_bundle.dart";
part "module_bundle/src/flutter_module_bundle.dart";
part "pypi/client.dart";
part "pypi/pypi.dart";
part "python_module.dart";
part "source_file.dart";
part "util.dart";
part "util/lazy_future.dart";

/// The version of dartpip.
const String kDartpipVersion = "0.1.0";
