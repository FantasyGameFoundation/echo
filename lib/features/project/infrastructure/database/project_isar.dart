import 'dart:io';

import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:isar/isar.dart';

final Map<String, Future<Isar>> _openProjectIsars = <String, Future<Isar>>{};

Future<Isar> openProjectIsar({
  String name = 'echo_projects',
  String? directoryPath,
}) async {
  final resolvedDirectory = directoryPath ?? await getAppStorageDirectoryPath();
  final existingInstance = Isar.getInstance(name);
  if (existingInstance != null && existingInstance.isOpen) {
    return existingInstance;
  }

  final cacheKey = '$name::$resolvedDirectory';
  final cachedOpen = _openProjectIsars[cacheKey];
  if (cachedOpen != null) {
    final cachedDatabase = await cachedOpen;
    if (cachedDatabase.isOpen) {
      return cachedDatabase;
    }
    _openProjectIsars.remove(cacheKey);
  }

  final openFuture = _openProjectIsarWithSchemas(
    resolvedDirectory: resolvedDirectory,
    name: name,
  );
  _openProjectIsars[cacheKey] = openFuture;

  try {
    final database = await openFuture;
    if (!database.isOpen) {
      _openProjectIsars.remove(cacheKey);
    }
    return database;
  } catch (error) {
    _openProjectIsars.remove(cacheKey);
    if (_isRecoverableInstanceError(error)) {
      await _closeLingeringProjectIsarInstance(name);
      return _openProjectIsarWithSchemas(
        resolvedDirectory: resolvedDirectory,
        name: name,
      );
    }
    if (_isRecoverableSchemaError(error)) {
      await _closeLingeringProjectIsarInstance(name);
      await _backupCorruptedProjectIsarFiles(
        resolvedDirectory: resolvedDirectory,
        name: name,
      );
      final retryFuture = _openProjectIsarWithSchemas(
        resolvedDirectory: resolvedDirectory,
        name: name,
      );
      _openProjectIsars[cacheKey] = retryFuture;
      try {
        return await retryFuture;
      } catch (retryError) {
        _openProjectIsars.remove(cacheKey);
        if (_isRecoverableInstanceError(retryError)) {
          await _closeLingeringProjectIsarInstance(name);
          return _openProjectIsarWithSchemas(
            resolvedDirectory: resolvedDirectory,
            name: name,
          );
        }
        rethrow;
      }
    }
    rethrow;
  }
}

bool _isRecoverableSchemaError(Object error) {
  final message = error.toString();
  return message.contains('Collection id is invalid');
}

bool _isRecoverableInstanceError(Object error) {
  final message = error.toString();
  return message.contains('Instance has already been opened.');
}

Future<Isar> _openProjectIsarWithSchemas({
  required String resolvedDirectory,
  required String name,
}) {
  return Isar.open(
    <CollectionSchema<dynamic>>[
      BeaconTaskSchema,
      ProjectSchema,
      ProjectSessionSchema,
      CaptureRecordSchema,
      NarrativeElementSchema,
      ProjectRelationTypeSchema,
      ProjectRelationGroupSchema,
      ProjectRelationMemberSchema,
      StructureChapterSchema,
    ],
    directory: resolvedDirectory,
    name: name,
    inspector: false,
  );
}

Future<void> _closeLingeringProjectIsarInstance(String name) async {
  final existingInstance = Isar.getInstance(name);
  if (existingInstance == null || !existingInstance.isOpen) {
    return;
  }

  try {
    await existingInstance.close();
  } catch (_) {}
}

Future<void> _backupCorruptedProjectIsarFiles({
  required String resolvedDirectory,
  required String name,
}) async {
  final directory = Directory(resolvedDirectory);
  if (!await directory.exists()) {
    return;
  }

  final backupSuffix = DateTime.now().toUtc().millisecondsSinceEpoch;
  await for (final entity in directory.list()) {
    final fileName = entity.uri.pathSegments.isNotEmpty
        ? entity.uri.pathSegments.last
        : '';
    if (!fileName.startsWith(name)) {
      continue;
    }

    final backupPath = '${entity.path}.corrupt-backup-$backupSuffix';
    try {
      await entity.rename(backupPath);
    } catch (_) {
      if (entity is File) {
        try {
          await entity.copy(backupPath);
          await entity.delete();
        } catch (_) {}
      }
    }
  }
}
