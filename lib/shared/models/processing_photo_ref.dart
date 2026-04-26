enum ProcessingPhotoStatus { processing, ready, failed }

class ProcessingPhotoRef {
  const ProcessingPhotoRef({
    required this.id,
    required this.sourcePath,
    required this.contextId,
    required this.status,
    this.importedPath,
    this.errorMessage,
  });

  factory ProcessingPhotoRef.processing({
    required String id,
    required String sourcePath,
    required String contextId,
  }) {
    return ProcessingPhotoRef(
      id: id,
      sourcePath: sourcePath,
      contextId: contextId,
      status: ProcessingPhotoStatus.processing,
    );
  }

  factory ProcessingPhotoRef.ready({
    required String id,
    required String sourcePath,
    required String importedPath,
    required String contextId,
  }) {
    return ProcessingPhotoRef(
      id: id,
      sourcePath: sourcePath,
      importedPath: importedPath,
      contextId: contextId,
      status: ProcessingPhotoStatus.ready,
    );
  }

  final String id;
  final String sourcePath;
  final String contextId;
  final ProcessingPhotoStatus status;
  final String? importedPath;
  final String? errorMessage;

  bool get isProcessing => status == ProcessingPhotoStatus.processing;
  bool get isReady => status == ProcessingPhotoStatus.ready;
  bool get isFailed => status == ProcessingPhotoStatus.failed;

  ProcessingPhotoRef copyWith({
    ProcessingPhotoStatus? status,
    String? importedPath,
    String? errorMessage,
  }) {
    return ProcessingPhotoRef(
      id: id,
      sourcePath: sourcePath,
      contextId: contextId,
      status: status ?? this.status,
      importedPath: importedPath ?? this.importedPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
