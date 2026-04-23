class SaveCaptureResult {
  const SaveCaptureResult({
    required this.recordId,
    this.photoCardElementId,
    this.textCardId,
  });

  final String recordId;
  final String? photoCardElementId;
  final String? textCardId;
}
