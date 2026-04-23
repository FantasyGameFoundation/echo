enum CaptureMode { recordOnly, photo, text, all }

extension CaptureModeX on CaptureMode {
  String get storageValue => switch (this) {
    CaptureMode.recordOnly => 'record-only',
    CaptureMode.photo => 'photo',
    CaptureMode.text => 'text',
    CaptureMode.all => 'all',
  };

  String get label => switch (this) {
    CaptureMode.recordOnly => '仅记录',
    CaptureMode.photo => '照片',
    CaptureMode.text => '文字',
    CaptureMode.all => '全部',
  };

  bool get allowsPhotoCards =>
      this == CaptureMode.photo || this == CaptureMode.all;

  bool get allowsTextCards =>
      this == CaptureMode.text || this == CaptureMode.all;

  static CaptureMode fromStorageValue(String value) {
    return switch (value) {
      'record-only' => CaptureMode.recordOnly,
      'photo' => CaptureMode.photo,
      'text' => CaptureMode.text,
      'all' => CaptureMode.all,
      _ => CaptureMode.recordOnly,
    };
  }
}
