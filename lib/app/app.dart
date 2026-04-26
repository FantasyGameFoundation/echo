import 'package:echo/app/shell/app_shell_page.dart';
import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/core/platform/project_bundle_file_transfer.dart';
import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/beacon/domain/repositories/beacon_task_repository.dart';
import 'package:echo/features/beacon/infrastructure/repositories/local_beacon_task_repository.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/models/save_capture_result.dart';
import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/capture/domain/services/save_capture_record.dart';
import 'package:echo/features/capture/infrastructure/repositories/local_capture_record_repository.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/repositories/local_project_repository.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:echo/features/settings/domain/services/export_project_bundle.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/services/local_export_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/services/local_import_project_bundle.dart';
import 'package:echo/features/settings/infrastructure/services/local_media_ingest_policy.dart';
import 'package:echo/features/settings/infrastructure/repositories/local_app_settings_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/infrastructure/repositories/local_structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

typedef SaveCaptureRecordRunner =
    Future<SaveCaptureResult> Function(SaveCaptureRequest request);

class EchoApp extends StatelessWidget {
  const EchoApp({
    super.key,
    this.projectRepository,
    this.structureChapterRepository,
    this.narrativeElementRepository,
    this.projectRelationRepository,
    this.narrativeElementPhotoPicker,
    this.narrativeElementPhotoImporter,
    this.capturePhotoPicker,
    this.saveCaptureRecord,
    this.captureRecordRepository,
    this.beaconTaskRepository,
    this.appSettingsRepository,
    this.exportProjectBundle,
    this.importProjectBundle,
    this.projectBundleFileTransfer,
  });

  static Future<Isar>? _sharedIsarFuture;

  static Future<Isar> _sharedOpenIsar() {
    return _sharedIsarFuture ??= openProjectIsar().catchError((error) {
      _sharedIsarFuture = null;
      throw error;
    });
  }

  static final ProjectRepository _defaultProjectRepository =
      LocalProjectRepository(openIsar: _sharedOpenIsar);
  static final StructureChapterRepository _defaultStructureChapterRepository =
      LocalStructureChapterRepository(openIsar: _sharedOpenIsar);
  static final NarrativeElementRepository _defaultNarrativeElementRepository =
      LocalNarrativeElementRepository(openIsar: _sharedOpenIsar);
  static final ProjectRelationRepository _defaultProjectRelationRepository =
      LocalProjectRelationRepository(openIsar: _sharedOpenIsar);
  static final BeaconTaskRepository _defaultBeaconTaskRepository =
      _buildDefaultBeaconTaskRepository();
  static final AppSettingsRepository _defaultAppSettingsRepository =
      _buildDefaultAppSettingsRepository();
  static final CaptureRecordRepository _defaultCaptureRecordRepository =
      _buildDefaultCaptureRecordRepository();
  static final SaveCaptureRecord _defaultSaveCaptureRecord = SaveCaptureRecord(
    openIsar: _sharedOpenIsar,
  );

  static CaptureRecordRepository _buildDefaultCaptureRecordRepository() {
    if (_isUnderWidgetTestRuntime) {
      return _NoopCaptureRecordRepository();
    }
    return LocalCaptureRecordRepository(openIsar: _sharedOpenIsar);
  }

  static BeaconTaskRepository _buildDefaultBeaconTaskRepository() {
    if (_isUnderWidgetTestRuntime) {
      return _NoopBeaconTaskRepository();
    }
    return LocalBeaconTaskRepository(openIsar: _sharedOpenIsar);
  }

  static AppSettingsRepository _buildDefaultAppSettingsRepository() {
    if (_isUnderWidgetTestRuntime) {
      return _NoopAppSettingsRepository();
    }
    return LocalAppSettingsRepository();
  }

  static bool get _isUnderWidgetTestRuntime {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('Test');
  }

  final ProjectRepository? projectRepository;
  final StructureChapterRepository? structureChapterRepository;
  final NarrativeElementRepository? narrativeElementRepository;
  final ProjectRelationRepository? projectRelationRepository;
  final PickGalleryImages? narrativeElementPhotoPicker;
  final ImportNarrativePhoto? narrativeElementPhotoImporter;
  final PickCapturedPhoto? capturePhotoPicker;
  final SaveCaptureRecordRunner? saveCaptureRecord;
  final CaptureRecordRepository? captureRecordRepository;
  final BeaconTaskRepository? beaconTaskRepository;
  final AppSettingsRepository? appSettingsRepository;
  final ExportProjectBundle? exportProjectBundle;
  final ImportProjectBundle? importProjectBundle;
  final ProjectBundleFileTransfer? projectBundleFileTransfer;

  BeaconTaskRepository get resolvedBeaconTaskRepository =>
      beaconTaskRepository ?? _defaultBeaconTaskRepository;

  AppSettingsRepository get resolvedAppSettingsRepository =>
      appSettingsRepository ?? _defaultAppSettingsRepository;

  @override
  Widget build(BuildContext context) {
    final resolvedSettingsRepository = resolvedAppSettingsRepository;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo',
      theme: AppTheme.light(),
      home: AppShellPage(
        projectRepository: projectRepository ?? _defaultProjectRepository,
        structureChapterRepository:
            structureChapterRepository ?? _defaultStructureChapterRepository,
        narrativeElementRepository:
            narrativeElementRepository ?? _defaultNarrativeElementRepository,
        projectRelationRepository:
            projectRelationRepository ?? _defaultProjectRelationRepository,
        beaconTaskRepository: resolvedBeaconTaskRepository,
        appSettingsRepository: resolvedSettingsRepository,
        exportProjectBundle:
            exportProjectBundle ??
            LocalExportProjectBundle(
              openProjectDatabase: _sharedOpenIsar,
              settingsRepository: resolvedSettingsRepository,
            ),
        importProjectBundle:
            importProjectBundle ??
            LocalImportProjectBundle(
              openProjectDatabase: _sharedOpenIsar,
              settingsRepository: resolvedSettingsRepository,
              mediaIngestPolicy: LocalMediaIngestPolicy(
                settingsRepository: resolvedSettingsRepository,
              ),
            ),
        captureRecordRepository:
            captureRecordRepository ?? _defaultCaptureRecordRepository,
        projectBundleFileTransfer:
            projectBundleFileTransfer ??
            const PlatformProjectBundleFileTransfer(),
        narrativeElementPhotoPicker: narrativeElementPhotoPicker,
        narrativeElementPhotoImporter: narrativeElementPhotoImporter,
        capturePhotoPicker: capturePhotoPicker,
        onSaveCaptureRecord:
            saveCaptureRecord ?? _defaultSaveCaptureRecord.execute,
      ),
    );
  }
}

class _NoopCaptureRecordRepository implements CaptureRecordRepository {
  final List<CaptureRecord> _records = <CaptureRecord>[];

  @override
  Future<CaptureRecord> createRecord({
    required String projectId,
    required String mode,
    String? rawText,
    required List<String> photoPaths,
  }) async {
    final record = CaptureRecord.create(
      projectId: projectId,
      captureMode: mode,
      captureText: rawText,
      capturedPhotoPaths: photoPaths,
      pendingPhotoPaths: photoPaths,
    );
    _records.add(record);
    return record;
  }

  @override
  Future<CaptureRecord?> getRecordById(String recordId) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<List<CaptureRecord>> listRecordsForProject(String projectId) async {
    return _records
        .where((record) => record.owningProjectId == projectId)
        .toList(growable: false);
  }

  @override
  Future<CaptureRecord?> updatePendingPhotoPaths({
    required String recordId,
    required List<String> pendingPhotoPaths,
  }) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        record.unorganizedPhotoPaths = List<String>.from(pendingPhotoPaths);
        return record;
      }
    }
    return null;
  }

  @override
  Future<CaptureRecord?> updateRecordPhotos({
    required String recordId,
    required List<String> photoPaths,
    required List<String> pendingPhotoPaths,
  }) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        record.photoPaths = List<String>.from(photoPaths);
        record.unorganizedPhotoPaths = List<String>.from(pendingPhotoPaths);
        record.updatedAt = DateTime.now();
        return record;
      }
    }
    return null;
  }

  @override
  Future<bool> deleteRecord(String recordId) async {
    final index = _records.indexWhere((record) => record.recordId == recordId);
    if (index < 0) {
      return false;
    }
    _records.removeAt(index);
    return true;
  }
}

class _NoopBeaconTaskRepository implements BeaconTaskRepository {
  final List<BeaconTask> _tasks = <BeaconTask>[];

  @override
  Future<List<BeaconTask>> listTasksForProject(String projectId) async {
    final matchingTasks = _tasks
        .where((task) => task.owningProjectId == projectId.trim())
        .toList(growable: false);
    matchingTasks.sort(
      (left, right) => right.updatedAt.compareTo(left.updatedAt),
    );
    return matchingTasks;
  }

  @override
  Future<BeaconTask> createTask({
    required String projectId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  }) async {
    final task = BeaconTask.create(
      projectId: projectId.trim(),
      taskTitle: title.trim(),
      taskDescription: description.trim(),
      linkedElementIds: linkedElementIds
          .map((elementId) => elementId.trim())
          .where((elementId) => elementId.isNotEmpty)
          .toList(growable: false),
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<BeaconTask?> updateTask({
    required String taskId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  }) async {
    for (final task in _tasks) {
      if (task.taskId == taskId) {
        task.title = title.trim();
        task.description = description.trim();
        task.linkedElementIds = linkedElementIds
            .map((elementId) => elementId.trim())
            .where((elementId) => elementId.isNotEmpty)
            .toList(growable: false);
        task.updatedAt = DateTime.now();
        return task;
      }
    }
    return null;
  }

  @override
  Future<BeaconTask?> archiveTask(String taskId) async {
    for (final task in _tasks) {
      if (task.taskId == taskId) {
        task.statusValue = BeaconTaskStatus.archived;
        task.updatedAt = DateTime.now();
        return task;
      }
    }
    return null;
  }

  @override
  Future<BeaconTask?> restoreTask(String taskId) async {
    for (final task in _tasks) {
      if (task.taskId == taskId) {
        task.statusValue = BeaconTaskStatus.pending;
        task.updatedAt = DateTime.now();
        return task;
      }
    }
    return null;
  }

  @override
  Future<bool> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.taskId == taskId);
    if (index < 0) {
      return false;
    }
    _tasks.removeAt(index);
    return true;
  }
}

class _NoopAppSettingsRepository implements AppSettingsRepository {
  AppSettings _settings = AppSettings.defaults();

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<AppSettings> save(AppSettings settings) async {
    _settings = settings.copyWith(updatedAt: DateTime.now());
    return _settings;
  }

  @override
  Future<AppSettings> update({
    AppMediaCompressionLevel? compressionLevel,
    bool? includeSettingsInExportsByDefault,
  }) async {
    return save(
      _settings.copyWith(
        compressionLevel: compressionLevel,
        includeSettingsInExportsByDefault: includeSettingsInExportsByDefault,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
