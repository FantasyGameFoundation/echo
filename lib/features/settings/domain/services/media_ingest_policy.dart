import 'package:echo/features/settings/domain/entities/app_settings.dart';

class MediaIngestPlan {
  const MediaIngestPlan({
    required this.compressionLevel,
    required this.preferredMaxShortEdgePx,
    required this.preferredMaxLongEdgePx,
  });

  final AppMediaCompressionLevel compressionLevel;
  final int? preferredMaxShortEdgePx;
  final int? preferredMaxLongEdgePx;

  bool get appliesCompression => compressionLevel.appliesCompression;
}

abstract class MediaIngestPolicy {
  Future<MediaIngestPlan> resolve({
    required String sourcePath,
    required String collection,
  });
}

class PassthroughMediaIngestPolicy implements MediaIngestPolicy {
  const PassthroughMediaIngestPolicy();

  @override
  Future<MediaIngestPlan> resolve({
    required String sourcePath,
    required String collection,
  }) async {
    return MediaIngestPlan(
      compressionLevel: AppMediaCompressionLevel.none,
      preferredMaxShortEdgePx: AppMediaCompressionLevel.none
          .preferredMaxShortEdgePx,
      preferredMaxLongEdgePx: AppMediaCompressionLevel.none
          .preferredMaxLongEdgePx,
    );
  }
}
