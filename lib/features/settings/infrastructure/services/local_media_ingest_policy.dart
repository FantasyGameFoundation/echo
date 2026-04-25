import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:echo/features/settings/domain/services/media_ingest_policy.dart';
import 'package:echo/features/settings/infrastructure/repositories/local_app_settings_repository.dart';

class LocalMediaIngestPolicy implements MediaIngestPolicy {
  LocalMediaIngestPolicy({AppSettingsRepository? settingsRepository})
    : _settingsRepository =
          settingsRepository ?? LocalAppSettingsRepository();

  final AppSettingsRepository _settingsRepository;

  @override
  Future<MediaIngestPlan> resolve({
    required String sourcePath,
    required String collection,
  }) async {
    final settings = await _settingsRepository.load();
    final compressionLevel = settings.compressionLevel;
    return MediaIngestPlan(
      compressionLevel: compressionLevel,
      preferredMaxShortEdgePx: compressionLevel.preferredMaxShortEdgePx,
      preferredMaxLongEdgePx: compressionLevel.preferredMaxLongEdgePx,
    );
  }
}
