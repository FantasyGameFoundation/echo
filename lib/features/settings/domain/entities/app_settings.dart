enum AppMediaCompressionLevel { none, highQuality, standard }

extension AppMediaCompressionLevelX on AppMediaCompressionLevel {
  String get storageValue => switch (this) {
    AppMediaCompressionLevel.none => 'none',
    AppMediaCompressionLevel.highQuality => 'high_quality',
    AppMediaCompressionLevel.standard => 'standard',
  };

  String get label => switch (this) {
    AppMediaCompressionLevel.none => '无压缩',
    AppMediaCompressionLevel.highQuality => '高质量',
    AppMediaCompressionLevel.standard => '标准',
  };

  static AppMediaCompressionLevel fromStorageValue(String? value) {
    return switch (value) {
      'none' => AppMediaCompressionLevel.none,
      'high_quality' => AppMediaCompressionLevel.highQuality,
      'balanced' => AppMediaCompressionLevel.standard,
      'storage_saver' => AppMediaCompressionLevel.standard,
      'standard' => AppMediaCompressionLevel.standard,
      _ => AppMediaCompressionLevel.none,
    };
  }

  bool get appliesCompression => this != AppMediaCompressionLevel.none;

  int? get preferredMaxShortEdgePx => switch (this) {
    AppMediaCompressionLevel.none => null,
    AppMediaCompressionLevel.highQuality => 2160,
    AppMediaCompressionLevel.standard => 1080,
  };

  int? get preferredMaxLongEdgePx => switch (this) {
    AppMediaCompressionLevel.none => null,
    AppMediaCompressionLevel.highQuality => 3840,
    AppMediaCompressionLevel.standard => 1920,
  };
}

class AppSettings {
  AppSettings({
    AppMediaCompressionLevel? compressionLevel,
    this.includeSettingsInExportsByDefault = false,
    DateTime? updatedAt,
  }) : compressionLevel = compressionLevel ?? AppMediaCompressionLevel.none,
       updatedAt = updatedAt ?? DateTime.now();

  factory AppSettings.defaults() => AppSettings();

  factory AppSettings.fromJson(Map<String, Object?> json) {
    final updatedAtValue = json['updatedAt'];
    return AppSettings(
      compressionLevel: AppMediaCompressionLevelX.fromStorageValue(
        json['compressionLevel'] as String?,
      ),
      includeSettingsInExportsByDefault:
          json['includeSettingsInExportsByDefault'] == true,
      updatedAt: updatedAtValue is String
          ? DateTime.tryParse(updatedAtValue)
          : null,
    );
  }

  final AppMediaCompressionLevel compressionLevel;
  final bool includeSettingsInExportsByDefault;
  final DateTime updatedAt;

  AppSettings copyWith({
    AppMediaCompressionLevel? compressionLevel,
    bool? includeSettingsInExportsByDefault,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      compressionLevel: compressionLevel ?? this.compressionLevel,
      includeSettingsInExportsByDefault:
          includeSettingsInExportsByDefault ??
          this.includeSettingsInExportsByDefault,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'compressionLevel': compressionLevel.storageValue,
      'includeSettingsInExportsByDefault': includeSettingsInExportsByDefault,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
