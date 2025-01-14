part of python_ffi_interface;

extension _SymbolToNameExtension on Symbol {
  String get name =>
      RegExp(r'^Symbol\("(.*)"\)$').firstMatch(toString())?.group(1) ??
      toString();
}
