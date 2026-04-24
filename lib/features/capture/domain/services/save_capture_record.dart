import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/models/save_capture_result.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

class SaveCaptureRecord {
  SaveCaptureRecord({
    Future<Isar> Function()? openIsar,
    DateTime Function()? clock,
  }) : _openIsar = openIsar ?? openProjectIsar,
       _clock = clock ?? DateTime.now;

  final Future<Isar> Function() _openIsar;
  final DateTime Function() _clock;
  Future<Isar>? _isarFuture;

  @visibleForTesting
  Future<void> Function()? debugBeforeDerivedRows;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  Future<SaveCaptureResult> execute(SaveCaptureRequest request) async {
    final database = await _database();
    final now = _clock();
    final normalizedProjectId = request.projectId.trim();
    final normalizedPhotoPaths = request.photoPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);

    late final CaptureRecord record;

    await database.writeTxn(() async {
      record = CaptureRecord.create(
        projectId: normalizedProjectId,
        captureMode: request.mode.storageValue,
        captureText: request.rawText,
        capturedPhotoPaths: normalizedPhotoPaths,
        pendingPhotoPaths: normalizedPhotoPaths,
        createdTimestamp: now,
        updatedTimestamp: now,
      );
      await database.captureRecords.put(record);

      if (debugBeforeDerivedRows != null) {
        await debugBeforeDerivedRows!();
      }
    });

    return SaveCaptureResult(
      recordId: record.recordId,
      photoCardElementId: null,
    );
  }

  Future<void> close() async {
    final database = await _database();
    await database.close();
    _isarFuture = null;
  }
}
