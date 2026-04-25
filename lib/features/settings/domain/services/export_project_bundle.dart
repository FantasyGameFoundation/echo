const int projectBundleFormatVersion = 1;
const String projectBundleManifestFileName = 'manifest.json';
const String projectBundleSettingsFileName = 'settings.json';
const String projectBundleMediaDirectoryName = 'media';

class ExportProjectBundleRequest {
  const ExportProjectBundleRequest({
    required this.projectId,
    required this.bundleDirectoryPath,
    this.includeSettings,
  });

  final String projectId;
  final String bundleDirectoryPath;
  final bool? includeSettings;
}

class ExportProjectBundleResult {
  const ExportProjectBundleResult({
    required this.bundleDirectoryPath,
    required this.manifestPath,
    required this.mediaCount,
    required this.includedSettings,
    this.settingsPath,
  });

  final String bundleDirectoryPath;
  final String manifestPath;
  final String? settingsPath;
  final int mediaCount;
  final bool includedSettings;
}

abstract class ExportProjectBundle {
  Future<ExportProjectBundleResult> execute(ExportProjectBundleRequest request);
}
