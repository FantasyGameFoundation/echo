import 'package:echo/features/capture/domain/entities/capture_record.dart';

abstract class CaptureRecordRepository {
  Future<CaptureRecord> createRecord({
    required String projectId,
    required String mode,
    String? rawText,
    required List<String> photoPaths,
  });

  Future<CaptureRecord?> getRecordById(String recordId);

  Future<List<CaptureRecord>> listRecordsForProject(String projectId);

  Future<CaptureRecord?> updatePendingPhotoPaths({
    required String recordId,
    required List<String> pendingPhotoPaths,
  });

  Future<CaptureRecord?> updateRecordPhotos({
    required String recordId,
    required List<String> photoPaths,
    required List<String> pendingPhotoPaths,
  });

  Future<bool> deleteRecord(String recordId);
}
