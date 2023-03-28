part of dartpip;

abstract class _ModuleBundle<T extends _PythonModule<Object>> {
  _ModuleBundle({
    required this.pythonModule,
    required this.appRoot,
  });

  final T pythonModule;
  final String appRoot;

  Directory get _appRootDirectory => Directory(appRoot);

  Directory get _pythonModuleDestinationDirectory;

  ByteData _transformSourceData(ByteData data) => data;

  String _transformSourceFileName(String fileName) => fileName;

  _SourceFile _sourceFile(String fileName) => _SourceFile(
        <String>[
          _pythonModuleDestinationDirectory.path,
          _transformSourceFileName(fileName)
        ].join(Platform.pathSeparator),
      );

  Future<void> _exportSingleFile(String fileName, ByteData data);

  Future<void> _exportMultiFile(Map<List<String>, ByteData> data) async {
    for (final MapEntry<List<String>, ByteData> entry in data.entries) {
      await _exportSingleFile(
        entry.key.join(Platform.pathSeparator),
        entry.value,
      );
    }
  }

  FutureOr<void> _postExport(List<List<String>> filePaths) {
    moduleInfo = _updateModuleInfo(moduleInfo);
  }

  Map<String, dynamic> get moduleInfo;

  set moduleInfo(Map<String, dynamic> moduleInfo);

  Map<String, dynamic> _updateModuleInfo(Map<String, dynamic> moduleInfo) =>
      moduleInfo
        ..update(
          pythonModule.moduleName,
          (Object? _) => pythonModule.moduleInfo,
          ifAbsent: () => pythonModule.moduleInfo,
        );

  Future<void> export() async {
    final T pythonModule = this.pythonModule;
    if (!(await pythonModule.load())) {
      throw StateError("Failed to load Python module.");
    }

    if (pythonModule is _SingleFilePythonModule) {
      await _exportSingleFile(
        pythonModule.fileName,
        _transformSourceData(pythonModule.data),
      );
      await _postExport(<List<String>>[
        <String>[pythonModule.fileName]
      ]);
    } else if (pythonModule is _MultiFilePythonModule) {
      await _exportMultiFile(
        pythonModule.data
            .mapKeys(
              (List<String> key) => <String>[pythonModule.moduleName, ...key],
            )
            .mapValues(_transformSourceData),
      );
      await _postExport(
        pythonModule.data.keys
            .map((List<String> e) => <String>[pythonModule.moduleName, ...e])
            .toList(),
      );
    }
  }
}