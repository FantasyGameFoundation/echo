import 'package:echo/features/settings/domain/entities/app_settings.dart';

abstract class AppSettingsRepository {
  Future<AppSettings> load();

  Future<AppSettings> save(AppSettings settings);

  Future<AppSettings> update({
    AppMediaCompressionLevel? compressionLevel,
    bool? includeSettingsInExportsByDefault,
  });
}
