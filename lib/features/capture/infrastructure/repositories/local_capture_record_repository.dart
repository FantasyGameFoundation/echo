import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:isar/isar.dart';

class LocalCaptureRecordRepository implements CaptureRecordRepository {
  LocalCaptureRecordRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  @override
  Future<CaptureRecord> createRecord({
    required String projectId,
    required String mode,
    String? rawText,
    required List<String> photoPaths,
  }) async {
    final database = await _database();
    final now = DateTime.now();
    final record = CaptureRecord.create(
      projectId: projectId.trim(),
      captureMode: mode,
      captureText: rawText,
      capturedPhotoPaths: photoPaths
          .map((path) => path.trim())
          .where((path) => path.isNotEmpty)
          .toList(growable: false),
      pendingPhotoPaths: photoPaths
          .map((path) => path.trim())
          .where((path) => path.isNotEmpty)
          .toList(growable: false),
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.captureRecords.put(record);
    });
    return record;
  }

  @override
  Future<CaptureRecord?> getRecordById(String recordId) async {
    final database = await _database();
    return database.captureRecords
        .filter()
        .recordIdEqualTo(recordId)
        .findFirst();
  }

  @override
  Future<List<CaptureRecord>> listRecordsForProject(String projectId) async {
    final database = await _database();
    final records = await database.captureRecords
        .filter()
        .owningProjectIdEqualTo(projectId.trim())
        .findAll();
    records.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return records;
  }

  @override
  Future<CaptureRecord?> updatePendingPhotoPaths({
    required String recordId,
    required List<String> pendingPhotoPaths,
  }) async {
    final database = await _database();
    final record = await database.captureRecords
        .filter()
        .recordIdEqualTo(recordId)
        .findFirst();
    if (record == null) {
      return null;
    }
    record.unorganizedPhotoPaths = pendingPhotoPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    record.updatedAt = DateTime.now();
    await database.writeTxn(() async {
      await database.captureRecords.put(record);
    });
    return record;
  }
}
