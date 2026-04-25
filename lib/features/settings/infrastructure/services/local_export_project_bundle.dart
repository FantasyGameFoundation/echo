import 'dart:convert';
import 'dart:io';

import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:echo/features/settings/domain/services/export_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/repositories/local_app_settings_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class LocalExportProjectBundle implements ExportProjectBundle {
  LocalExportProjectBundle({
    Future<Isar> Function()? openProjectDatabase,
    AppSettingsRepository? settingsRepository,
  }) : _openProjectDatabase = openProjectDatabase ?? openProjectIsar,
       _settingsRepository =
           settingsRepository ?? LocalAppSettingsRepository();

  final Future<Isar> Function() _openProjectDatabase;
  final AppSettingsRepository _settingsRepository;
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openProjectDatabase().catchError((error) {
      _isarFuture = null;
      throw error;
    });
  }

  @override
  Future<ExportProjectBundleResult> execute(
    ExportProjectBundleRequest request,
  ) async {
    final bundleDirectory = Directory(request.bundleDirectoryPath);
    await _prepareBundleDirectory(bundleDirectory);

    try {
      final database = await _database();
      final projectId = request.projectId.trim();
      final project = await database.projects
          .filter()
          .projectIdEqualTo(projectId)
          .findFirst();
      if (project == null) {
        throw StateError('Project not found: $projectId');
      }

      final captures = await database.captureRecords
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();
      final chapters = await database.structureChapters
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();
      final elements = await database.narrativeElements
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();
      final relationTypes = await database.projectRelationTypes
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();
      final relationGroups = await database.projectRelationGroups
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();
      final relationMembers = await database.projectRelationMembers
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();
      final beaconTasks = await database.beaconTasks
          .filter()
          .owningProjectIdEqualTo(projectId)
          .findAll();

      final mediaDirectory = Directory(
        p.join(bundleDirectory.path, projectBundleMediaDirectoryName),
      );
      await mediaDirectory.create(recursive: true);
      final mediaPaths = _collectMediaPaths(
        project: project,
        captures: captures,
        elements: elements,
        relationMembers: relationMembers,
      );
      final mediaPathMap = await _copyMediaIntoBundle(
        sourcePaths: mediaPaths,
        mediaDirectory: mediaDirectory,
      );

      final settings = await _settingsRepository.load();
      final includeSettings =
          request.includeSettings ?? settings.includeSettingsInExportsByDefault;

      final manifest = <String, Object?>{
        'formatVersion': projectBundleFormatVersion,
        'project': _serializeProject(project, mediaPathMap),
        'captures': captures.map((record) {
          return _serializeCaptureRecord(record, mediaPathMap);
        }).toList(growable: false),
        'chapters': chapters.map(_serializeChapter).toList(growable: false),
        'narrativeElements': elements.map((element) {
          return _serializeNarrativeElement(element, mediaPathMap);
        }).toList(growable: false),
        'relationTypes': relationTypes
            .map(_serializeRelationType)
            .toList(growable: false),
        'relationGroups': relationGroups
            .map(_serializeRelationGroup)
            .toList(growable: false),
        'relationMembers': relationMembers.map((member) {
          return _serializeRelationMember(member, mediaPathMap);
        }).toList(growable: false),
        'beaconTasks': beaconTasks
            .map(_serializeBeaconTask)
            .toList(growable: false),
        'mediaEntries': mediaPathMap.entries.map((entry) {
          return <String, Object?>{
            'relativePath': entry.value,
          };
        }).toList(growable: false),
      };

      final manifestPath = p.join(
        bundleDirectory.path,
        projectBundleManifestFileName,
      );
      await File(manifestPath).writeAsString(_encoder.convert(manifest));

      String? settingsPath;
      if (includeSettings) {
        settingsPath = p.join(
          bundleDirectory.path,
          projectBundleSettingsFileName,
        );
        await File(settingsPath).writeAsString(
          _encoder.convert(settings.toJson()),
        );
      }

      return ExportProjectBundleResult(
        bundleDirectoryPath: bundleDirectory.path,
        manifestPath: manifestPath,
        settingsPath: settingsPath,
        mediaCount: mediaPathMap.length,
        includedSettings: includeSettings,
      );
    } catch (_) {
      if (await bundleDirectory.exists()) {
        await bundleDirectory.delete(recursive: true);
      }
      rethrow;
    }
  }

  Future<void> _prepareBundleDirectory(Directory bundleDirectory) async {
    if (await bundleDirectory.exists()) {
      if (!await bundleDirectory.list().isEmpty) {
        throw StateError(
          'Bundle directory must be empty: ${bundleDirectory.path}',
        );
      }
      return;
    }

    await bundleDirectory.create(recursive: true);
  }

  Future<Map<String, String>> _copyMediaIntoBundle({
    required Set<String> sourcePaths,
    required Directory mediaDirectory,
  }) async {
    final copiedPaths = <String, String>{};

    for (final sourcePath in sourcePaths) {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw StateError('Bundle export media file is missing: $sourcePath');
      }

      final relativePath =
          '$projectBundleMediaDirectoryName/${const Uuid().v4()}${p.extension(sourcePath)}';
      final targetPath = p.join(mediaDirectory.parent.path, relativePath);
      await sourceFile.copy(targetPath);
      copiedPaths[sourcePath] = relativePath;
    }

    return copiedPaths;
  }

  Set<String> _collectMediaPaths({
    required Project project,
    required List<CaptureRecord> captures,
    required List<NarrativeElement> elements,
    required List<ProjectRelationMember> relationMembers,
  }) {
    final mediaPaths = <String>{};

    void addPath(String? path) {
      final trimmedPath = path?.trim();
      if (trimmedPath == null || trimmedPath.isEmpty) {
        return;
      }
      mediaPaths.add(trimmedPath);
    }

    addPath(project.coverImagePath);
    for (final record in captures) {
      for (final photoPath in record.photoPaths) {
        addPath(photoPath);
      }
      for (final photoPath in record.unorganizedPhotoPaths) {
        addPath(photoPath);
      }
    }
    for (final element in elements) {
      for (final photoPath in element.photoPaths) {
        addPath(photoPath);
      }
    }
    for (final member in relationMembers) {
      addPath(member.linkedPhotoPath);
    }

    return mediaPaths;
  }

  Map<String, Object?> _serializeProject(
    Project project,
    Map<String, String> mediaPathMap,
  ) {
    return <String, Object?>{
      'projectId': project.projectId,
      'title': project.title,
      'themeStatement': project.themeStatement,
      'description': project.description,
      'coverImagePath': _rewriteMediaPath(project.coverImagePath, mediaPathMap),
      'stage': project.stage,
      'createdAt': project.createdAt.toUtc().toIso8601String(),
      'updatedAt': project.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeCaptureRecord(
    CaptureRecord record,
    Map<String, String> mediaPathMap,
  ) {
    return <String, Object?>{
      'recordId': record.recordId,
      'mode': record.mode,
      'rawText': record.rawText,
      'photoPaths': record.photoPaths
          .map((path) => _rewriteMediaPath(path, mediaPathMap))
          .whereType<String>()
          .toList(growable: false),
      'unorganizedPhotoPaths': record.unorganizedPhotoPaths
          .map((path) => _rewriteMediaPath(path, mediaPathMap))
          .whereType<String>()
          .toList(growable: false),
      'createdAt': record.createdAt.toUtc().toIso8601String(),
      'updatedAt': record.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeChapter(StructureChapter chapter) {
    return <String, Object?>{
      'chapterId': chapter.chapterId,
      'title': chapter.title,
      'description': chapter.description,
      'statusLabel': chapter.statusLabel,
      'elementCount': chapter.elementCount,
      'sortOrder': chapter.sortOrder,
      'createdAt': chapter.createdAt.toUtc().toIso8601String(),
      'updatedAt': chapter.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeNarrativeElement(
    NarrativeElement element,
    Map<String, String> mediaPathMap,
  ) {
    return <String, Object?>{
      'elementId': element.elementId,
      'owningChapterId': element.owningChapterId,
      'title': element.title,
      'description': element.description,
      'status': element.status,
      'sortOrder': element.sortOrder,
      'photoPaths': element.photoPaths
          .map((path) => _rewriteMediaPath(path, mediaPathMap))
          .whereType<String>()
          .toList(growable: false),
      'createdAt': element.createdAt.toUtc().toIso8601String(),
      'updatedAt': element.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeRelationType(ProjectRelationType relationType) {
    return <String, Object?>{
      'relationTypeId': relationType.relationTypeId,
      'name': relationType.name,
      'description': relationType.description,
      'sortOrder': relationType.sortOrder,
      'createdAt': relationType.createdAt.toUtc().toIso8601String(),
      'updatedAt': relationType.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeRelationGroup(
    ProjectRelationGroup relationGroup,
  ) {
    return <String, Object?>{
      'relationGroupId': relationGroup.relationGroupId,
      'linkedRelationTypeId': relationGroup.linkedRelationTypeId,
      'title': relationGroup.title,
      'description': relationGroup.description,
      'createdAt': relationGroup.createdAt.toUtc().toIso8601String(),
      'updatedAt': relationGroup.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeRelationMember(
    ProjectRelationMember member,
    Map<String, String> mediaPathMap,
  ) {
    return <String, Object?>{
      'relationMemberId': member.relationMemberId,
      'owningGroupId': member.owningGroupId,
      'kind': member.kind,
      'linkedElementId': member.linkedElementId,
      'linkedPhotoPath': _rewriteMediaPath(member.linkedPhotoPath, mediaPathMap),
      'linkedSourceElementId': member.linkedSourceElementId,
      'memberSortOrder': member.memberSortOrder,
      'createdAt': member.createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, Object?> _serializeBeaconTask(BeaconTask task) {
    return <String, Object?>{
      'taskId': task.taskId,
      'title': task.title,
      'description': task.description ?? '',
      'status': task.status,
      'linkedElementIds': List<String>.from(task.linkedElementIds),
      'createdAt': task.createdAt.toUtc().toIso8601String(),
      'updatedAt': task.updatedAt.toUtc().toIso8601String(),
    };
  }

  String? _rewriteMediaPath(String? sourcePath, Map<String, String> mediaPathMap) {
    final trimmedPath = sourcePath?.trim();
    if (trimmedPath == null || trimmedPath.isEmpty) {
      return null;
    }
    return mediaPathMap[trimmedPath];
  }
}
