import 'dart:convert';
import 'dart:io';

import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:path/path.dart' as p;

class LocalAppSettingsRepository implements AppSettingsRepository {
  LocalAppSettingsRepository({
    Future<String> Function()? resolveStorageDirectoryPath,
  }) : _resolveStorageDirectoryPath =
           resolveStorageDirectoryPath ?? getAppStorageDirectoryPath;

  final Future<String> Function() _resolveStorageDirectoryPath;
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  Future<File> _settingsFile() async {
    final storageRoot = await _resolveStorageDirectoryPath();
    final settingsDirectory = Directory(p.join(storageRoot, 'settings'));
    await settingsDirectory.create(recursive: true);
    return File(p.join(settingsDirectory.path, 'app_settings.json'));
  }

  @override
  Future<AppSettings> load() async {
    final file = await _settingsFile();
    if (!await file.exists()) {
      return AppSettings.defaults();
    }

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw StateError('Settings file must contain a JSON object.');
    }

    return AppSettings.fromJson(
      decoded.map<String, Object?>(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  @override
  Future<AppSettings> save(AppSettings settings) async {
    final file = await _settingsFile();
    final normalized = AppSettings(
      compressionLevel: settings.compressionLevel,
      includeSettingsInExportsByDefault:
          settings.includeSettingsInExportsByDefault,
      updatedAt: DateTime.now(),
    );

    await file.writeAsString(_encoder.convert(normalized.toJson()));
    return normalized;
  }

  @override
  Future<AppSettings> update({
    AppMediaCompressionLevel? compressionLevel,
    bool? includeSettingsInExportsByDefault,
  }) async {
    final current = await load();
    return save(
      current.copyWith(
        compressionLevel: compressionLevel,
        includeSettingsInExportsByDefault:
            includeSettingsInExportsByDefault,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
