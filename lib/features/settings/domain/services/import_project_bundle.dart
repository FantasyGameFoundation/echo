class ImportProjectBundleInspection {
  const ImportProjectBundleInspection({
    required this.hasSettingsPayload,
    required this.oversizedMediaCount,
  });

  final bool hasSettingsPayload;
  final int oversizedMediaCount;
}

class ImportProjectBundleRequest {
  const ImportProjectBundleRequest({
    required this.bundleDirectoryPath,
    this.applyImportedSettings = false,
  });

  final String bundleDirectoryPath;
  final bool applyImportedSettings;
}

class ImportProjectBundleResult {
  const ImportProjectBundleResult({
    required this.importedProjectId,
    required this.importedProjectTitle,
    required this.importedMediaCount,
    required this.hadSettingsPayload,
    required this.appliedImportedSettings,
  });

  final String importedProjectId;
  final String importedProjectTitle;
  final int importedMediaCount;
  final bool hadSettingsPayload;
  final bool appliedImportedSettings;
}

abstract class ImportProjectBundle {
  Future<ImportProjectBundleInspection> inspect(String bundleDirectoryPath);

  Future<ImportProjectBundleResult> execute(ImportProjectBundleRequest request);
}
