import 'dart:convert';
import 'dart:io';

import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/models/project_session.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:echo/features/settings/domain/services/export_project_bundle.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:echo/features/settings/domain/services/media_ingest_policy.dart';
import 'package:echo/features/settings/infrastructure/repositories/local_app_settings_repository.dart';
import 'package:echo/features/settings/infrastructure/services/local_media_ingest_policy.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class LocalImportProjectBundle implements ImportProjectBundle {
  LocalImportProjectBundle({
    Future<Isar> Function()? openProjectDatabase,
    AppSettingsRepository? settingsRepository,
    MediaIngestPolicy? mediaIngestPolicy,
  }) : _openProjectDatabase = openProjectDatabase ?? openProjectIsar,
       _settingsRepository =
           settingsRepository ?? LocalAppSettingsRepository(),
       _mediaIngestPolicy =
           mediaIngestPolicy ??
           LocalMediaIngestPolicy(
             settingsRepository:
                 settingsRepository ?? LocalAppSettingsRepository(),
           );

  final Future<Isar> Function() _openProjectDatabase;
  final AppSettingsRepository _settingsRepository;
  final MediaIngestPolicy _mediaIngestPolicy;

  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openProjectDatabase().catchError((error) {
      _isarFuture = null;
      throw error;
    });
  }

  @override
  Future<ImportProjectBundleInspection> inspect(
    String bundleDirectoryPath,
  ) async {
    final bundleDirectory = Directory(bundleDirectoryPath);
    if (!await bundleDirectory.exists()) {
      throw StateError('Bundle directory does not exist: $bundleDirectoryPath');
    }

    final manifest = await _readRequiredJsonMap(
      p.join(bundleDirectory.path, projectBundleManifestFileName),
    );
    final settingsPath = p.join(
      bundleDirectoryPath,
      projectBundleSettingsFileName,
    );
    final hasSettingsPayload = await File(settingsPath).exists();
    final mediaEntries = _readMapList(manifest, 'mediaEntries');
    var oversizedMediaCount = 0;

    for (final entry in mediaEntries) {
      final relativePath = _readRequiredString(entry, 'relativePath');
      final sourcePath = p.join(bundleDirectoryPath, relativePath);
      final plan = await _mediaIngestPolicy.resolve(
        sourcePath: sourcePath,
        collection: 'projects/import_inspection',
      );
      final bounds = await inspectMediaImageBounds(sourcePath);
      if (bounds != null && isMediaImageOversizedForPlan(bounds, plan)) {
        oversizedMediaCount += 1;
      }
    }

    return ImportProjectBundleInspection(
      hasSettingsPayload: hasSettingsPayload,
      oversizedMediaCount: oversizedMediaCount,
    );
  }

  @override
  Future<ImportProjectBundleResult> execute(
    ImportProjectBundleRequest request,
  ) async {
    final bundleDirectory = Directory(request.bundleDirectoryPath);
    if (!await bundleDirectory.exists()) {
      throw StateError('Bundle directory does not exist: ${bundleDirectory.path}');
    }

    final manifest = await _readRequiredJsonMap(
      p.join(bundleDirectory.path, projectBundleManifestFileName),
    );
    final formatVersion = _readRequiredInt(manifest, 'formatVersion');
    if (formatVersion != projectBundleFormatVersion) {
      throw UnsupportedError(
        'Unsupported project bundle format: $formatVersion',
      );
    }

    final settingsPath = p.join(
      bundleDirectory.path,
      projectBundleSettingsFileName,
    );
    final hadSettingsPayload = await File(settingsPath).exists();
    final importedSettings = hadSettingsPayload
        ? AppSettings.fromJson(await _readRequiredJsonMap(settingsPath))
        : null;

    final database = await _database();
    final previousSession = await database.projectSessions.get(0);
    final previousCurrentProjectId = previousSession?.currentProjectId;
    final previousSettings =
        request.applyImportedSettings && importedSettings != null
        ? await _settingsRepository.load()
        : null;

    final newProjectId = const Uuid().v4();
    final importedMediaPaths = <String>[];
    var transactionCommitted = false;
    var importedSettingsApplied = false;

    try {
      final importedMediaMap = await _importMediaAssets(
        bundleDirectoryPath: bundleDirectory.path,
        mediaEntries: _readMapList(manifest, 'mediaEntries'),
        projectId: newProjectId,
        importedMediaPaths: importedMediaPaths,
      );

      final projectMap = _readRequiredMap(manifest, 'project');
      final importedProjectTitle = _readRequiredString(projectMap, 'title');

      final project = Project.create(
        id: newProjectId,
        projectTitle: importedProjectTitle,
        projectThemeStatement: _readRequiredString(projectMap, 'themeStatement'),
        projectDescription: _readNullableString(projectMap, 'description'),
        projectCoverImagePath: _rewriteImportedMediaPath(
          _readNullableString(projectMap, 'coverImagePath'),
          importedMediaMap,
        ),
        projectStage: _readRequiredString(projectMap, 'stage'),
        createdTimestamp: _readRequiredDateTime(projectMap, 'createdAt'),
        updatedTimestamp: _readRequiredDateTime(projectMap, 'updatedAt'),
      );

      final chapters = _readMapList(manifest, 'chapters').map((chapterMap) {
        return StructureChapter.create(
          id: _readRequiredString(chapterMap, 'chapterId'),
          projectId: newProjectId,
          chapterTitle: _readRequiredString(chapterMap, 'title'),
          chapterDescription: _readNullableString(chapterMap, 'description'),
          chapterStatus: _readRequiredString(chapterMap, 'statusLabel'),
          chapterElementCount: _readRequiredInt(chapterMap, 'elementCount'),
          chapterSortOrder: _readRequiredInt(chapterMap, 'sortOrder'),
          createdTimestamp: _readRequiredDateTime(chapterMap, 'createdAt'),
          updatedTimestamp: _readRequiredDateTime(chapterMap, 'updatedAt'),
        );
      }).toList(growable: false);

      final elements = _readMapList(
        manifest,
        'narrativeElements',
      ).map((elementMap) {
        return NarrativeElement.create(
          id: _readRequiredString(elementMap, 'elementId'),
          projectId: newProjectId,
          chapterId: _readNullableString(elementMap, 'owningChapterId'),
          elementTitle: _readRequiredString(elementMap, 'title'),
          elementDescription: _readNullableString(elementMap, 'description'),
          elementStatus: _readRequiredString(elementMap, 'status'),
          elementSortOrder: _readRequiredInt(elementMap, 'sortOrder'),
          linkedPhotoPaths: _readStringList(elementMap, 'photoPaths')
              .map((path) => _rewriteImportedMediaPath(path, importedMediaMap)!)
              .toList(growable: false),
          createdTimestamp: _readRequiredDateTime(elementMap, 'createdAt'),
          updatedTimestamp: _readRequiredDateTime(elementMap, 'updatedAt'),
        );
      }).toList(growable: false);

      final captures = _readMapList(manifest, 'captures').map((captureMap) {
        return CaptureRecord.create(
          id: _readRequiredString(captureMap, 'recordId'),
          projectId: newProjectId,
          captureMode: _readRequiredString(captureMap, 'mode'),
          captureText: _readNullableString(captureMap, 'rawText') ?? '',
          capturedPhotoPaths: _readStringList(captureMap, 'photoPaths')
              .map((path) => _rewriteImportedMediaPath(path, importedMediaMap)!)
              .toList(growable: false),
          pendingPhotoPaths: _readStringList(
            captureMap,
            'unorganizedPhotoPaths',
          ).map((path) => _rewriteImportedMediaPath(path, importedMediaMap)!)
              .toList(growable: false),
          createdTimestamp: _readRequiredDateTime(captureMap, 'createdAt'),
          updatedTimestamp: _readRequiredDateTime(captureMap, 'updatedAt'),
        );
      }).toList(growable: false);

      final relationTypes = _readMapList(
        manifest,
        'relationTypes',
      ).map((relationTypeMap) {
        return ProjectRelationType.create(
          id: _readRequiredString(relationTypeMap, 'relationTypeId'),
          projectId: newProjectId,
          relationName: _readRequiredString(relationTypeMap, 'name'),
          relationDescription: _readRequiredString(
            relationTypeMap,
            'description',
          ),
          relationSortOrder: _readRequiredInt(relationTypeMap, 'sortOrder'),
          createdTimestamp: _readRequiredDateTime(relationTypeMap, 'createdAt'),
          updatedTimestamp: _readRequiredDateTime(relationTypeMap, 'updatedAt'),
        );
      }).toList(growable: false);

      final relationGroups = _readMapList(
        manifest,
        'relationGroups',
      ).map((relationGroupMap) {
        return ProjectRelationGroup.create(
          id: _readRequiredString(relationGroupMap, 'relationGroupId'),
          projectId: newProjectId,
          relationTypeId: _readRequiredString(
            relationGroupMap,
            'linkedRelationTypeId',
          ),
          relationGroupTitle: _readNullableString(relationGroupMap, 'title'),
          relationGroupDescription: _readNullableString(
            relationGroupMap,
            'description',
          ),
          createdTimestamp: _readRequiredDateTime(
            relationGroupMap,
            'createdAt',
          ),
          updatedTimestamp: _readRequiredDateTime(
            relationGroupMap,
            'updatedAt',
          ),
        );
      }).toList(growable: false);

      final relationMembers = _readMapList(
        manifest,
        'relationMembers',
      ).map((memberMap) {
        return ProjectRelationMember.create(
          id: _readRequiredString(memberMap, 'relationMemberId'),
          projectId: newProjectId,
          groupId: _readRequiredString(memberMap, 'owningGroupId'),
          targetKind: _readRequiredString(memberMap, 'kind'),
          elementId: _readNullableString(memberMap, 'linkedElementId'),
          photoPath: _rewriteImportedMediaPath(
            _readNullableString(memberMap, 'linkedPhotoPath'),
            importedMediaMap,
          ),
          sourceElementId: _readNullableString(
            memberMap,
            'linkedSourceElementId',
          ),
          sortOrder: _readRequiredInt(memberMap, 'memberSortOrder'),
          createdTimestamp: _readRequiredDateTime(memberMap, 'createdAt'),
        );
      }).toList(growable: false);

      final beaconTasks = _readMapList(manifest, 'beaconTasks').map((taskMap) {
        return BeaconTask.create(
          id: _readRequiredString(taskMap, 'taskId'),
          projectId: newProjectId,
          taskTitle: _readRequiredString(taskMap, 'title'),
          taskDescription: _readNullableString(taskMap, 'description') ?? '',
          linkedElementIds: _readStringList(taskMap, 'linkedElementIds'),
          taskStatus: _readRequiredString(taskMap, 'status'),
          createdTimestamp: _readRequiredDateTime(taskMap, 'createdAt'),
          updatedTimestamp: _readRequiredDateTime(taskMap, 'updatedAt'),
        );
      }).toList(growable: false);

      await database.writeTxn(() async {
        await database.projects.put(project);
        if (chapters.isNotEmpty) {
          await database.structureChapters.putAll(chapters);
        }
        if (elements.isNotEmpty) {
          await database.narrativeElements.putAll(elements);
        }
        if (captures.isNotEmpty) {
          await database.captureRecords.putAll(captures);
        }
        if (relationTypes.isNotEmpty) {
          await database.projectRelationTypes.putAll(relationTypes);
        }
        if (relationGroups.isNotEmpty) {
          await database.projectRelationGroups.putAll(relationGroups);
        }
        if (relationMembers.isNotEmpty) {
          await database.projectRelationMembers.putAll(relationMembers);
        }
        if (beaconTasks.isNotEmpty) {
          await database.beaconTasks.putAll(beaconTasks);
        }
        await database.projectSessions.put(
          ProjectSession()..currentProjectId = newProjectId,
        );
      });
      transactionCommitted = true;

      if (request.applyImportedSettings && importedSettings != null) {
        await _settingsRepository.save(importedSettings);
        importedSettingsApplied = true;
      }

      return ImportProjectBundleResult(
        importedProjectId: newProjectId,
        importedProjectTitle: importedProjectTitle,
        importedMediaCount: importedMediaMap.length,
        hadSettingsPayload: hadSettingsPayload,
        appliedImportedSettings: importedSettingsApplied,
      );
    } catch (_) {
      if (transactionCommitted) {
        await _rollbackImportedProject(
          projectId: newProjectId,
          previousCurrentProjectId: previousCurrentProjectId,
        );
      }
      await _cleanupImportedFiles(importedMediaPaths);
      if (importedSettingsApplied && previousSettings != null) {
        try {
          await _settingsRepository.save(previousSettings);
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<Map<String, String>> _importMediaAssets({
    required String bundleDirectoryPath,
    required List<Map<String, Object?>> mediaEntries,
    required String projectId,
    required List<String> importedMediaPaths,
  }) async {
    final importedMediaMap = <String, String>{};

    for (final entry in mediaEntries) {
      final relativePath = _readRequiredString(entry, 'relativePath');
      final sourcePath = p.join(bundleDirectoryPath, relativePath);
      final importedFile = await importMediaFileWithPolicy(
        sourcePath: sourcePath,
        collection: 'projects/$projectId',
        policy: _mediaIngestPolicy,
      );
      importedMediaMap[relativePath] = importedFile.path;
      importedMediaPaths.add(importedFile.path);
    }

    return importedMediaMap;
  }

  Future<void> _rollbackImportedProject({
    required String projectId,
    required String? previousCurrentProjectId,
  }) async {
    final database = await _database();

    final projects = await database.projects
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
    final chapters = await database.structureChapters
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    final elements = await database.narrativeElements
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    final captures = await database.captureRecords
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

    await database.writeTxn(() async {
      if (beaconTasks.isNotEmpty) {
        await database.beaconTasks.deleteAll(
          beaconTasks.map((task) => task.isarId).toList(growable: false),
        );
      }
      if (relationMembers.isNotEmpty) {
        await database.projectRelationMembers.deleteAll(
          relationMembers.map((member) => member.isarId).toList(growable: false),
        );
      }
      if (relationGroups.isNotEmpty) {
        await database.projectRelationGroups.deleteAll(
          relationGroups.map((group) => group.isarId).toList(growable: false),
        );
      }
      if (relationTypes.isNotEmpty) {
        await database.projectRelationTypes.deleteAll(
          relationTypes
              .map((relationType) => relationType.isarId)
              .toList(growable: false),
        );
      }
      if (captures.isNotEmpty) {
        await database.captureRecords.deleteAll(
          captures.map((record) => record.isarId).toList(growable: false),
        );
      }
      if (elements.isNotEmpty) {
        await database.narrativeElements.deleteAll(
          elements.map((element) => element.isarId).toList(growable: false),
        );
      }
      if (chapters.isNotEmpty) {
        await database.structureChapters.deleteAll(
          chapters.map((chapter) => chapter.isarId).toList(growable: false),
        );
      }
      if (projects.isNotEmpty) {
        await database.projects.deleteAll(
          projects.map((project) => project.isarId).toList(growable: false),
        );
      }
      await database.projectSessions.put(
        ProjectSession()..currentProjectId = previousCurrentProjectId,
      );
    });
  }

  Future<void> _cleanupImportedFiles(List<String> importedMediaPaths) async {
    for (final importedPath in importedMediaPaths) {
      final file = File(importedPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<Map<String, Object?>> _readRequiredJsonMap(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Required bundle file is missing: $filePath');
    }

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw StateError('Bundle file must decode to a JSON object: $filePath');
    }

    return decoded.map<String, Object?>(
      (key, value) => MapEntry(key.toString(), value),
    );
  }

  List<Map<String, Object?>> _readMapList(
    Map<String, Object?> source,
    String key,
  ) {
    final rawList = source[key];
    if (rawList == null) {
      return const <Map<String, Object?>>[];
    }
    if (rawList is! List) {
      throw StateError('Bundle value "$key" must be a JSON array.');
    }

    return rawList.map((item) {
      if (item is! Map) {
        throw StateError('Bundle array "$key" must contain only objects.');
      }
      return item.map<String, Object?>(
        (entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue),
      );
    }).toList(growable: false);
  }

  Map<String, Object?> _readRequiredMap(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];
    if (value is! Map) {
      throw StateError('Bundle value "$key" must be a JSON object.');
    }

    return value.map<String, Object?>(
      (entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue),
    );
  }

  String _readRequiredString(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is! String || value.trim().isEmpty) {
      throw StateError('Bundle value "$key" must be a non-empty string.');
    }
    return value;
  }

  String? _readNullableString(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw StateError('Bundle value "$key" must be a string or null.');
    }
    return value;
  }

  int _readRequiredInt(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    throw StateError('Bundle value "$key" must be an integer.');
  }

  DateTime _readRequiredDateTime(Map<String, Object?> source, String key) {
    final value = _readRequiredString(source, key);
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw StateError('Bundle value "$key" must be an ISO-8601 datetime.');
    }
    return parsed;
  }

  List<String> _readStringList(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value == null) {
      return const <String>[];
    }
    if (value is! List) {
      throw StateError('Bundle value "$key" must be a JSON array.');
    }

    return value.map((item) {
      if (item is! String) {
        throw StateError('Bundle array "$key" must contain only strings.');
      }
      return item;
    }).toList(growable: false);
  }

  String? _rewriteImportedMediaPath(
    String? relativePath,
    Map<String, String> importedMediaMap,
  ) {
    final trimmedPath = relativePath?.trim();
    if (trimmedPath == null || trimmedPath.isEmpty) {
      return null;
    }

    final importedPath = importedMediaMap[trimmedPath];
    if (importedPath == null) {
      throw StateError('Bundle media entry is missing for path: $trimmedPath');
    }
    return importedPath;
  }
}
