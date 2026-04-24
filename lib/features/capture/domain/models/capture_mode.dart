enum CaptureMode { record, portfolio }

extension CaptureModeX on CaptureMode {
  String get storageValue => switch (this) {
    CaptureMode.record => 'record',
    CaptureMode.portfolio => 'portfolio',
  };

  String get label => switch (this) {
    CaptureMode.record => '记录',
    CaptureMode.portfolio => '作品',
  };

  static CaptureMode fromStorageValue(String value) {
    return switch (value) {
      'record' => CaptureMode.record,
      'portfolio' => CaptureMode.portfolio,
      _ => CaptureMode.record,
    };
  }
}
