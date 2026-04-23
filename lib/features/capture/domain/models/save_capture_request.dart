import 'package:echo/features/capture/domain/models/capture_mode.dart';

class SaveCaptureRequest {
  const SaveCaptureRequest({
    required this.projectId,
    required this.mode,
    required this.rawText,
    required this.photoPaths,
  });

  final String projectId;
  final CaptureMode mode;
  final String rawText;
  final List<String> photoPaths;

  List<String> get importedPhotoPaths => photoPaths;
}
